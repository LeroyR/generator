;;;; recipe-repository.lisp --- A repository for directory and filename information.
;;;;
;;;; Copyright (C) 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:jenkins.model.project)

(defclass recipe-repository ()
  ((%root-directory     :initarg  :root-directory
                        :type     (and pathname (satisfies uiop:directory-pathname-p))
                        :reader   root-directory
                        :documentation
                        "The root directory of the repository.")
   (%recipe-directories :type     hash-table
                        :reader   %recipe-directories
                        :initform (make-hash-table :test #'eq)
                        :documentation
                        "A map of recipe kinds to sub-directories."))
  (:default-initargs
   :root-directory (missing-required-initarg 'recipe-repository :root-directory))
  (:documentation
   "Stores a repository root and sub-directories for recipe kinds."))

(defmethod print-items:print-items append ((object recipe-repository))
  `((:root-path ,(root-directory object) "~A")))

(defun make-recipe-repository (root-directory)
  (make-instance 'recipe-repository :root-directory root-directory))

(defun populate-recipe-repository! (repository mode)
  (let ((template-directory (make-pathname :directory (list :relative
                                                            "templates"
                                                            mode))))
    (setf (recipe-directory :template     repository) template-directory
          (recipe-directory :project      repository) #P"projects/"
          (recipe-directory :distribution repository) #P"distributions/"
          (recipe-directory :person       repository) #P"persons/")
    repository))

(defun make-populated-recipe-repository (root-directory mode)
  (populate-recipe-repository! (make-recipe-repository root-directory) mode))

(defmethod recipe-directory ((kind t) (repository recipe-repository))
  (let ((relative (or (gethash kind (%recipe-directories repository))
                      (error "~@<~A does not have a sub-directory for ~
                              recipes of kind ~A.~@:>"
                             repository kind))))
    (merge-pathnames relative (root-directory repository))))

(defmethod (setf recipe-directory) ((new-value  pathname)
                                    (kind       t)
                                    (repository recipe-repository))
  (unless (uiop:directory-pathname-p new-value)
    (error "~@<~A is not a directory pathname.~@:>" new-value))

  (setf (gethash kind (%recipe-directories repository)) new-value))

;;; `recipe-path'

(defmethod recipe-path ((repository recipe-repository)
                        (kind       t)
                        (name       string))
  (let* ((components (split-sequence:split-sequence #\/ name))
         (directory  (list* :relative (butlast components)))
         (name       (lastcar components))
         (pathname   (make-pathname :directory directory
                                    :name      name)))
    (recipe-path repository kind pathname)))

(defmethod recipe-path ((repository recipe-repository)
                        (kind       t)
                        (name       (eql :wild)))
  (recipe-path repository kind (make-pathname :name name)))

(defmethod recipe-path ((repository recipe-repository)
                        (kind       t)
                        (name       pathname))
  (let* ((directory  (recipe-directory kind repository))
         (type       (string-downcase kind))
         (defaults   (make-pathname :type type :defaults directory)))
    (merge-pathnames name defaults)))

;;; `recipe-truename'

(defmethod recipe-truename :around ((repository recipe-repository)
                                    (kind       t)
                                    (name       t)
                                    &key
                                    (if-does-not-exist #'error))
  (or (call-next-method repository kind name :if-does-not-exist nil)
      (error-behavior-restart-case
          (if-does-not-exist (recipe-not-found-error
                              :kind       kind
                              :name       name
                              :repository repository)))))

(defmethod recipe-truename ((repository recipe-repository)
                            (kind       t)
                            (name       t)
                            &key if-does-not-exist)
  (declare (ignore if-does-not-exist))
  (let ((pathname (recipe-path repository kind name)))
    (cond ((and (wild-pathname-p pathname) (directory pathname))
           pathname)
          ((and (not (wild-pathname-p pathname)) (probe-file pathname))
           pathname))))
