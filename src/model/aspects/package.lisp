;;;; package.lisp --- Package definition for aspects module.
;;;;
;;;; Copyright (C) 2015, 2016, 2017, 2019 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:defpackage #:jenkins.model.aspects
  (:use
   #:cl
   #:alexandria
   #:split-sequence
   #:iterate
   #:let-plus
   #:more-conditions
   #:print-items

   #:jenkins.model
   #:jenkins.model.variables

   #:jenkins.api
   #:jenkins.dsl)

  (:shadowing-import-from #:jenkins.model ; TODO hack
   #:name)

  (:shadowing-import-from #:jenkins.model.variables ; TODO hack
   #:as)

  (:shadowing-import-from #:jenkins.api ; TODO hack
   #:parameters)

  (:shadowing-import-from #:jenkins.dsl ; TODO hack
   #:job)

  ;; Conditions
  (:export
   #:parameter-condition
   #:parameter-condition-aspect
   #:parameter-condition-parameter

   #:missing-argument-error

   #:argument-condition
   #:argument-condition-value

   #:argument-type-error)

  ;; Aspect parameter protocol
  (:export
   #:aspect-parameter-variable
   #:aspect-parameter-binding-name
   #:aspect-parameter-default-value)

  ;; Aspect protocol
  (:export
   #:aspect-parameters
   #:aspect-process-parameters
   #:aspect-process-parameter

   #:aspect<

   #:extend!)

  ;; Aspect creation protocol
  (:export
   #:make-aspect)

  ;; Aspect container protocol
  (:export
   #:aspects)

  (:documentation
   "Aspects extend the target being generated with behavior fragments."))
