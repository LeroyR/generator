;;;; package.lisp --- Package definition for api module.
;;;;
;;;; Copyright (C) 2012, 2013, 2014 Jan Moringen
;;;;
;;;; Author: Jan Moringen <jmoringe@techfak.uni-bielefeld.de>

(cl:defpackage #:jenkins.api
  (:use
   #:cl
   #:alexandria
   #:split-sequence
   #:iterate
   #:let-plus
   #:more-conditions)

  ;; Variables
  (:export
   #:*base-url*
   #:*username*
   #:*password*)

  ;; API
  (:export
   #:id
   #:commit!)

  ;; Node
  (:export
   #:node

   #:node
   #:all-nodes
   #:node-config
   #:make-node
   #:delete-node

   #:name
   #:description
   #:host
   #:mode
   #:label
   #:environment

   #:online?
   #:mark-online!
   #:mark-offline!)

  ;; Job
  (:export
   #:job

   #:job ;; TODO find-job?
   #:all-jobs ;; TODO jobs?
   #:job-config
   #:job?
   #:make-job
   #:delete-job

   #:kind                           ; matrix or regular; setfable
   #:description
   #:upstream
   #:children
   #:keep/days
   #:keep/count
   #:block-on-downstream-build?
   #:block-on-upstream-build?

   #:properties     #:properties-of-type
   #:triggers       #:triggers-of-type ; Interface-based children
   #:repository                     ; Note: only one repository
   #:build-wrappers #:build-wrappers-of-type
   #:builders       #:builders-of-type
   #:publishers     #:publishers-of-type

   #:slaves                         ; Not sure about these
   #:environment
   #:permissions

   #:copy-job/fixup
   #:build!
   #:enable!
   #:disable!

   #:relate                         ; Up/downstream relations
   #:unrelate)

  ;; SCM interface
  (:export
   #:scm/git
   #:url
   #:branches
   #:local-branch
   #:wipe-out-workspace?
   #:checkout-submodules?
   #:skip-internal-tag?
   #:browser-kind
   #:browser-url

   #:scm/svn
   #:url
   #:local-directory
   #:checkout-strategy

   #:scm/bzr
   #:url)

  ;; Properties interface
  (:export
   #:property/parameters
   #:parameters)

  ;; Trigger interface
  (:export
   #:trigger/scm
   #:spec
   #:ignore-post-commit-hooks?

   #:trigger/timer
   #:spec

   #:trigger/github
   #:spec)

  ;; Build-wrapper interface
  (:export
   #:build-wrapper/timeout
   #:kind
   #:timeout/minutes
   #:faild-build?)

  ;; Builder interface
  (:export
   #:builder/shell
   #:command

   #:builder/batch
   #:command

   #:builder/cmake
   #:command

   #:builder/ant
   #:targets
   #:properties

   #:builder/maven
   #:targets
   #:properties
   #:private-repository?

   #:builder/copy-artifact
   #:project-name
   #:filter
   #:target
   #:flatten?)

  ;; Publisher interface
  (:export
   #:publisher/ssh
   #:target
   #:remote-directory

   #:publisher/warnings
   #:file-parsers
   #:console-parsers

   #:warning-parser/file
   #:pattern
   #:name

   #:warning-parser/console
   #:name

   #:publisher/tasks
   #:threshold-limit
   #:keywords/low
   #:keywords/normal
   #:keywords/high

   #:publisher/archive-artifacts
   #:files
   #:only-latest?

   #:publisher/fingerprint
   #:targets
   #:build-artifacts?

   #:publisher/junit
   #:result-files
   #:keep-long-stdio?

   #:publisher/cobertura
   #:report-file

   #:publisher/html)

  ;; Build
  (:export
   #:build

   #:build
   #:all-builds
   #:last-builds
   #:build-config
   #:make-build
   #:delete-build

   #:job
   #:slave
   #:slave-name
   #:result
   #:building?
   #:failed?)

  ;; View
  (:export
   #:view

   #:view
   #:all-views
   #:view-config
   #:make-view
   #:delete-view

   #:jobs)

  (:documentation
   "TODO")
  (:export
   ))