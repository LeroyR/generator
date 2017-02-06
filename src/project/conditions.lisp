;;;; conditions.lisp --- Conditions used by the project module.
;;;;
;;;; Copyright (C) 2012-2017 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:in-package #:jenkins.project)

;;; Variable-related conditions

(define-condition expression-cycle-error (error)
  ((path :initarg :path
         :type    list
         :reader  expression-cycle-error-path))
  (:report
   (lambda (condition stream)
     (format stream "~@<The following expression evaluation lead to a ~
                     cycle:~
                     ~@:_~@:_    ~{~{~24A in ~A~}~^~@:_ -> ~}~
                     ~@:_~@:_.~@:>"
            (expression-cycle-error-path condition))))
  (:default-initargs
   :path (missing-required-initarg 'expression-cycle-error :path))
  (:documentation
   "This error is signaled when a cycle is detected during variable
    expansion."))

;;; Instantiation-related conditions

(define-condition instantiation-condition (chainable-condition)
  ((specification :initarg  :specification
                  :reader   instantiation-condition-specification
                  :documentation
                  ""))
  (:default-initargs
   :specification (missing-required-initarg
                   'instantiation-condition :specification))
  (:documentation
   "Subclasses of this condition are signaled to indicate certain
    condition during the instantiation of specifications."))

(define-condition instantiation-error (error
                                       instantiation-condition)
  ()
  (:report
   (lambda (condition stream)
     (format stream "~@<Error during instantiation of ~
                     ~{~A~^ » ~}~/more-conditions:maybe-print-cause/~@:>"
             (labels ((ancestors (thing) ; TODO make a method
                        (cons thing
                              (when (and (compute-applicable-methods #'parent (list thing))
                                         (parent thing))
                                (ancestors (parent thing))))))
               (nreverse
                (ancestors (instantiation-condition-specification condition))))
             condition)))
  (:documentation
   "This error is signaled when an error is encountered during the
    instantiation of a specification."))

;;; Deployment-related conditions

(define-condition deployment-condition (chainable-condition)
  ((thing :initarg  :thing
          :reader   deployment-condition-thing
          :documentation
          ""))
  (:default-initargs
   :thing (missing-required-initarg 'deployment-condition :thing))
  (:documentation
   "Subclasses of this condition are signaled to indicate certain
    conditions during the deployment of things."))

(define-condition deployment-error (error
                                    deployment-condition)
  ()
  (:report
   (lambda (condition stream)
     (format stream "~@<Error during deployment of ~
                     ~{~A~^ » ~}~/more-conditions:maybe-print-cause/~@:>"
             (labels ((ancestors (thing) ; TODO make/use method
                        (cons thing
                              (when (and (compute-applicable-methods #'parent (list thing))
                                         (parent thing))
                                (ancestors (parent thing))))))
               (nreverse
                (ancestors (deployment-condition-thing condition))))
             condition)))
  (:documentation
   "This error is signaled when an error is encountered during
    deployment of a thing."))
