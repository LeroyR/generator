;;;; jenkins-install.lisp --- Steps for setting up a Jenkins instance.
;;;;
;;;; Copyright (C) 2015, 2016, 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:jenkins.project.steps)

;;; `jenkins/install-core' step

(define-constant +default-jenkins-download-url+
    (puri:uri "http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war")
  :test #'puri:uri=)

(define-step (jenkins/install-core)
    ((url                  +default-jenkins-download-url+)
     destination-directory)
  "Download the Jenkins archive into a specified directory."
  (let ((pathname (merge-pathnames "jenkins.war" destination-directory)))
    (ensure-directories-exist pathname)
    (when (not (probe-file pathname))
      (jenkins.analysis::download-file url pathname))))

;;; `jenkins/install-plugins[-with-dependencies]' steps

(define-constant +jenkins-plugin-directory+
  #P"plugins/"
  :test #'equalp)

(define-constant +jenkins-plugin-manifest-filename+
  "META-INF/MANIFEST.MF"
  :test #'string=)

(define-constant +jenkins-plugins-base-url+
    (puri:uri "https://updates.jenkins-ci.org/latest/")
  :test #'puri:uri=)

(defun jenkins-plugin-pathname (base-directory name)
  (merge-pathnames (make-pathname :name     name
                                  :type     "hpi"
                                  :defaults +jenkins-plugin-directory+)
                   base-directory))

(defun jenkins-plugin-url (name &key (base-url +jenkins-plugins-base-url+))
  (puri:merge-uris (format nil "~A.hpi" name) base-url))

(defgeneric jenkins-plugin-dependencies (thing)
  (:method ((thing string))
    (let+ ((clean (ppcre:regex-replace-all
                   #.(format nil "~C~%(:? )?" #\Return) thing
                   (lambda (whole space)
                     (declare (ignore whole))
                     (if (emptyp space) (string #\Newline) ""))
                   :simple-calls t))
           ((&flet parse-dependency (spec)
              (ppcre:register-groups-bind (name version optional?)
                  ("([^:]+):([^;]+)(;resolution:=optional)?" spec)
                (list name version (when optional? t))))))
      (ppcre:register-groups-bind (dependencies)
          ("Plugin-Dependencies: +(.+)" clean)
        (mapcar #'parse-dependency
                (split-sequence:split-sequence #\, dependencies)))))
  (:method ((thing pathname))
    (jenkins-plugin-dependencies
     (zip:with-zipfile (zip thing)
       (let ((manifest (zip:get-zipfile-entry +jenkins-plugin-manifest-filename+ zip)))
         (sb-ext:octets-to-string (zip:zipfile-entry-contents manifest)))))))

(define-sequence-step (jenkins/install-plugins plugin plugins
                       :execution :parallel
                       :progress  nil)
    (destination-directory)
  "Add specified plugins to an existing Jenkins installation."
  (progress :install/plugin nil "~A" plugin)
  (let ((pathname (jenkins-plugin-pathname destination-directory plugin))
        (url      (jenkins-plugin-url plugin)))
    (unless (probe-file pathname)
      (log:info "~@<Installing ~A from ~A into ~A.~@:>" plugin url pathname)
      (jenkins.analysis::download-file url pathname)
      (jenkins-plugin-dependencies pathname))))

(define-step (jenkins/install-plugins-with-dependencies)
    (destination-directory plugins)
  "Add plugins to a Jenkins installation, honoring plugin dependencies."
  (let+ ((step      (make-step :jenkins/install-plugins))
         (installed '())
         ((&flet install (round plugins)
            (log:info "~@<Installing plugins with dependencies round
                       ~D: ~{~A~^, ~}.~@:>"
                      round plugins)
            (appendf installed plugins)
            (let* ((dependencies (execute
                                  step :context
                                  :destination-directory destination-directory
                                  :plugins               plugins))
                   (dependencies (mapcar #'first
                                         (remove-if #'third
                                                    (mappend #'identity dependencies))))
                   (dependencies (remove-duplicates dependencies :test #'string=)))
              (set-difference dependencies installed :test #'string=)))))
    (with-trivial-progress (:install/plugin)
      (ensure-directories-exist (jenkins-plugin-pathname
                                 destination-directory "dummy"))
      (loop :for i :from 0
            :for missing = plugins :then (install i missing)
            :while missing))))

;;; `jenkins/install-config-files' step

(defparameter *jenkins-config-files*
  '#.(let ((data-directory (merge-pathnames
                            (make-pathname
                             :name      :unspecific
                             :type      :unspecific
                             :directory '(:relative
                                          :back :back
                                          "data" "jenkins-install" "config"))
                            (or *compile-file-truename*
                                *load-truename*))))
       (map 'list (lambda (filename)
                    (list (enough-namestring filename data-directory)
                          (read-file-into-byte-vector filename)
                          #+unix (logand #o777 (sb-posix:stat-mode
                                                (sb-posix:stat filename)))
                          #-unix nil))
            (directory (merge-pathnames "**/*.*" data-directory)))))

(define-sequence-step (jenkins/install-config-files file-info config-files
                       :progress :install/config-file)
    (destination-directory)
  "Install Jenkins configuration files into a specified directory."
  (let+ (((filename content mode) file-info))
    (progress "~A" filename)
    (let ((destination-file (merge-pathnames
                             filename destination-directory)))
      (ensure-directories-exist destination-file)
      (write-byte-vector-into-file content destination-file
                                   :if-exists :supersede)
      #+unix (sb-posix:chmod destination-file mode))))

;;; `jenkins/create-user' step

(defparameter *jenkins-user-config-file-template*
  #.(let ((filename (merge-pathnames
                     "../../data/jenkins-install/user-config.xml.in"
                     (or *compile-file-truename* *load-truename*))))
      (read-file-into-byte-vector filename)))

(macrolet ((define-xpath-constant (name xpath)
             `(define-constant ,name
                  `(xpath:xpath ,(xpath:parse-xpath ,xpath))
                :test #'equal)))

  (define-xpath-constant +jenkins-user-config-full-name-path+
    "/user/fullName/text()")

  (define-xpath-constant +jenkins-user-config-password-hash-path+
    "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash/text()")

  (define-xpath-constant +jenkins-user-config-email-path+
    "/user/properties/hudson.tasks.Mailer_-UserProperty/emailAddress/text()"))

(define-step (jenkins/create-user)
    (destination-directory config-file-template
     username email password)
  "Create a user in an existing Jenkins installation."
  (with-trivial-progress (:install/user "~A" username)
   (let* ((destination-file (merge-pathnames
                             (make-pathname :name      "config"
                                            :type      "xml"
                                            :directory `(:relative "users" ,username))
                             destination-directory))
          (hash             (jenkins.project.bcrypt:hash-password password))
          (hash             (format nil "#jbcrypt:~A" hash))
          (document         (cxml:parse config-file-template
                                        (stp:make-builder))))
     ;; Populate template.
     (mapc (lambda+ ((path . value))
             (xpath:do-node-set (node (xpath:evaluate path document))
               (setf (stp:data node) value)))
           `((,+jenkins-user-config-full-name-path+     . ,username)
             (,+jenkins-user-config-password-hash-path+ . ,hash)
             (,+jenkins-user-config-email-path+         . ,email)))
     ;; Serialize modified document into the user configuration file
     ;; for USERNAME.
     (ensure-directories-exist destination-file)
     (with-output-to-file (stream destination-file
                                  :element-type '(unsigned-byte 8)
                                  :if-exists    :supersede)
       (stp:serialize document (cxml:make-octet-stream-sink stream))))))