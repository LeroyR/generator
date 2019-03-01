((:release "0.27" nil

  (:enhancement
   "The new" (:verb "install-jenkins") "command downloads, installs
    and configures a Jenkins instance into a given directory. To avoid
    Jenkins' initial setup wizard, a user account is also created.")

  (:enhancement
   "When analyzing Git repositories, the" (:verb "git ls-remote")
   "invocation is no longer mandatory in all cases. Instead, results
    of these invocations are stored in a timestamped cached and reused
    while still recent enough."
   "The new configuration
    option" (:verb "global.cache-age-limit") "and the corresponding
    commandline option" (:verb "cache-age-limit") "control how long
    after their creation cached results are still considered recent
    enough. The default value is" (:verb "1800") "seconds.")

  (:enhancement
   "The new" (:verb "config") "command allows inspecting configuration
    sources and the current configuration."))

 (:release "0.26" "2019-02-19"

  (:enhancement
   "The HTML report publisher plugin for Jenkins is now supported.")

  (:enhancement
   "When the first attempt at cloning a mercurial repository fails, a
    second attempt without using \"bundles\" is made.")

  (:enhancement
   "Error reports printed during the analysis and deployment phases
    now always include the project and/or project version name.")

  (:enhancement
   "The \"Jenkins Warnings Plugin - Next Generation\" plugin is now
    supported. However, generated job configurations continue to
    select the legacy warnings and tasks plugins by default."
   "The following commandline options can be used to generate job
    configurations which select the new plugin:"
   (:verb "-D aspect.checkstyle.implementation=ng
-D aspect.pmd.implementation=ng
-D aspect.tasks.implementation=ng
-D aspect.warnings.implementation=ng"))

  (:enhancement
   "The behavior in case of errors can now be controlled at a finer
    level of granularity. To this end, the" (:verb "on-error")
   "commandline option, in addition to the previous values, now
    accepts a policy specification adhering to the following grammar:"
   (:verb "error-policy ::= rule* default
rule         ::= error \"=>\" action \":\"
error        ::= \"object-error\" | \"simple-object-error\"
                 | \"syntax-error\" | \"repository-access-error\"
                 | \"repository-analysis-error\"
                 | \"project-analysis-error\" | \"analysis-error\"
                 | \"dependency-error\" | \"instantiation-error\"
                 | \"deployment-error\" | \"report-error\"
default      ::= action
action       ::= \"abort\" | \"fail\" | \"continue\" | \"debug\"")
   ("Example:")
   (:verb "
  dependency-error=>continue:analysis-error=>fail:abort
")
   ("The above continues the run with exit code zero in case")
   (:verb "dependency-error") "s are encountered, continues and
    returns a non-zero exit code for" (:verb "analysis-error") ("s and
    immediately aborts with non-zero exit code for all other
    errors."))

  (:enhancement
   "Distribution recipes can now include other distribution recipes in
    a new" (:verb "include") "section."
   "Distribution includes can be written in two forms, either"
   (:verb "include:
- NAME")
   "or"
   (:verb "- name: NAME
  parameters:
    PARAMETER₁: VALUE₁
    PARAMETER₂: VALUE₂
    ⋮")
   "where" (:verb "NAME") "is the name of a distribution (without file
    extension) and PARAMTERₖ: VALUEₖ are variable bindings that should
    overwrite bindings in the included distribution. Included
    distributions can in turn include other distributions."
   "Variables referenced in projects (and jobs and aspects) are now
    looked up in the following order (most specific, highest priority
    first):"
   (:ul
    "Specified as a parameter when (directly) including the project
     version in a distribution"
    ("Specified as a variable in an entry in the" (:verb "versions") "
      section of the project recipe")
    ("Specified as a variable in the global" (:verb "variables") "
      section of the project recipe")
    "Specified as a parameter when including the distribution which in
     turn directly includes the project version"
    "Specified as a variable in the distribution which directly
     includes the project version"
    "Specified a as variable in the \"outermost\" (that is, given on
     the commandline) distribution")
   "If a given project version is included in multiple distributions,
    the instance (and in particular the parameters of that instance)
    that appears first in terms of a depth-first traversal
    of" (:verb "include") "relations is used while all others are
    discarded."
   "Note that the textual order of the" (:verb "include") "and"
   (:verb "versions") "sections in distribution recipes has no bearing
    on the ordering described above."))

 (:release "0.25" "2018-11-14"

  (:incompatible-change
   "JSON syntax in recipes is no longer explicitly supported but note
    that the current YAML syntax includes JSON as a subset. For
    recipes which are syntactically valid JSON, differences in
    behavior may arise around line breaks in quoted strings.")

  (:enhancement
   "Entries in the" (:verb "versions") "section of project recipes now
    allow using the key" (:verb "pattern") "instead
    of" (:verb "name") "for specifying the name of the version. The
    corresponding value must be a regular expression which may contain
    capture groups. In case" (:verb "pattern") "is used, project
    versions specified in distribution recipes are scanned using the
    regular expression and matching ones are considered existing
    project versions. Within such a project version section, the
    variables" (:verb "version-name") "," (:verb "match:0") ","
    (:verb "match:1") "," (:verb "match:2") ", … are bound to the
    whole matched string and the values of the capture groups in the
    pattern respectively."
   "For example, matching" (:verb "0.15-test") "against the
    pattern" (:verb "^([0-9]+\.[0-9]+)-(.*)$") "results in bindings"
   (:ul
    (:verb "version-name → 0.15-test")
    (:verb "match:0      → 0.15-test")
    (:verb "match:1      → 0.15")
    (:verb "match:2      → test"))
   "These variables can be used in definitions of other variables in
    the project version such as" (:verb "branch") "."
   "Full example:"
   (:verb "versions:
- pattern: '^(.*)-without-tests$'
  variables:
    branch: ${match:1}
    cmake.options:
    - '@{next-value}'
    - -DBUILD_TESTS=false"))

  (:enhancement
   "Jobs and aspects defined in the orchestration context can now pick
    up variable overwrites specified on the commandline.")

  (:enhancement
   "Most commands (notably " (:verb "generate") ") now work properly
    when multiple distributions are specified in a single commandline
    invocation of the program.")

  (:enhancement
   "When analyzing committers and commits in git repositories the
    specified sub-directory, if any, is now considered.")

  (:enhancement
   "Recipes describing persons can now contain
    a" (:verb "variables") "section.")

  (:enhancement
   "The new" (:verb "catalog") "report type outputs files in a format
    that can be consumed by the citkat catalog server.")

  (:enhancement
   "When analyzing CMake projects, the project version can now be
    determined when a" (:verb "PROJECT-NAMEConfigVersion.cmake.in")
   "or" (:verb "PROJECT-NAME-config-version.cmake.in") "file refers to
    a variable containing the project version.")

  (:enhancement
   "Error messages from access consistency checks display the
    locations of the incompatible declarations, if possible."))

 (:release "0.24" "2018-09-17"

  (:incompatible-change
   "The default of the" (:verb "--on-error") "commandline option is
    now" (:verb "continue") "since the overwhelming majority of use
    cases seem to mandate this value.")

  (:enhancement
   "When analyzing CMake projects," (:verb "include()") "commands are
    now considered.")

  (:enhancement
   "When analyzing CMake projects, variable references are evaluated
    more accurately and more efficiently.")

  (:enhancement
   "When analyzing CMake projects, the" (:verb "VERSION") "keyword of
    the" (:verb "project()") "command is now considered.")

  (:enhancement
   "Unfulfilled dependencies are reported more compactly.")

  (:enhancement
   "The SonarCube Scanner plugin for standard build steps such as
    Ant, Maven and Gradle is now supported.")

  (:enhancement
   "Boolean parameters for Jenkins jobs are now supported."))

 (:release "0.23" "2018-07-20"

  (:enhancement
   "The YAML syntax for recipes now supports including other YAML
    documents as well as text files:"
   (:ul
    ("A tagged scalar node of the form"
     (:verb "!b!include FILENAME")
     "causes" (:verb "FILENAME") "to be loaded as a YAML file and
      spliced into the current recipe, replacing the tagged scalar
      node.")
    ("A tagged scalar node of the form"
     (:verb "!b!literal-include FILENAME")
     "causes" (:verb "FILENAME") "to be read as a string and spliced
      into the current recipe, replacing the tagged scalar node.")))

  (:enhancement
   "Better error reports for syntax errors and missing templates in
    YAML recipes.")

  (:enhancement
   "During the analysis phase, certain kinds of failed HTTP downloads
    now lead to a limited number of retries instead of an immediate
    failure.")

  (:enhancement
   "Errors during report generation are now reported with their own
    error kind.")

  (:enhancement
   "Information for Gitea repositories can now be generated into the
    configuration of the Jenkins Git plugin.")

  (:enhancement
   "The" (:verb "analyze") "command now handles URIs and filesystem
    paths properly.")

  (:enhancement
   "A warning is no longer emitted when automatically switching from
    JSON to YAML syntax for a recipe.")

  (:bugfix
   "A long-standing problem related non-ASCII characters in Jenkins
    job data has been fixed by working around the way Jenkins handles
    HTTP content types and XML encoding declarations.")

  (:bugfix
   "The" (:verb "temp-directory") "and" (:verb "cache-directory") "configuration
    options are now explicitly interpreted as directory names. This
    solves issues with directories specified without a trailing
    \"/\"."))

 (:release "0.22" "2018-06-08"

  (:enhancement
   "Recipes can now be written using YAML syntax following (mostly)
    the same structural schema as before. As JSON is a subset of YAML,
    the legacy JSON syntax and in particular existing recipes are
    still supported. The following differences are noteworthy:"
   (:ul
    ("Comments are now allowed and can be written as" (:verb "# comment"))
    ("Many string literals can be written in vastly improved manner:"
     (:ul
      "Quotes and escaping are not necessary in most cases"
      "Multi-line strings pose no problems"
      "A suitable interpretation of surrounding whitespace and
       indentation can be specified as appropriate"))
    ("The" (:verb "name") "attribute is not allowed in project,
      distribution and template recipes")
    ("The inclusion of projects in distributions can now be written in
      several different ways:"
     (:ul
      ("Old way for compatibility:"
       (:verb "[ \"NAME\", VERSION₁, VERSION₂, …]") "where
       each" (:verb "VERSION") "is either a string or"
       (:verb "[ \"NAME\", { \"PARAMETER₁\": \"VALUE₁\", … } ] "))
      ("New way, compact:" (:verb "NAME@VERSION") "or"
       (:verb "NAME … @VERSION") "to allow the"
       (:verb "NAME₁             @VERSION₁
MUCH-LONGER-NAME₂ @VERSION₂")
       "idiom")
      ("New way, single version with parameters:"
       (:verb "name: NAME
version: VERSION
parameters:
  PARAMETER₁: VALUE₁
  PARAMETER₂: VALUE₂"))
      ("New way, multiple versions with or without parameters:"
       (:verb "name: NAME
versions:
- version: VERSION₁
  parameters:
    PARAMETER₁₁: VALUE₁₁
    PARAMETER₁₂: VALUE₁₂
- version: VERSION₂"))))
    ("Dependency specifications can now be written in several
     different ways:"
     (:ul
      ("Old way for compatibility:"
       (:verb "[ \"NATURE\", \"TARGET\" ]") "or"
       (:verb "[ \"NATURE\",\"TARGET\", VERSION ]") "where"
       (:verb "VERSION") "is either a string or a list of version
        component strings")
      ("New way:"
       (:verb "nature: NATURE
target: TARGET
version: VERSION")
       "where the" (:verb "version") "property is optional")))))

  (:enhancement
   "The new" (:verb "validate") "command checks the syntax and
    referential integrity of recipes in a given recipe repository.")

  (:enhancement
   "Analysis results for projects using" (:variable "scm")
   (:verb "archive") "can now be cached.")

  (:enhancement
   "Better error messages for missing or wrong arguments to
    commandline options.")

  (:enhancement
   "More cases of ill-formed recipes are caught at parse-time.")

  (:bugfix
   "The" (:verb "trace-variable") "commandline option has been
    restored.")

  (:bugfix
   "The" (:verb "generate") "command accepts a"
   (:verb "-a API-TOKEN") "commandline argument like the old
    commandline interface.")

  (:bugfix
   "Supplying single-value commandline options multiple times now
    produces a suitable error message."))

 (:release "0.21" "2018-05-07"

  (:incompatible-change
   "The commandline interface expects a sub-command that determines
    what should be done (instead of always generating Jenkins
    jobs). The previous behavior is mostly provided by the
    \"generate\" command with some differences:"
   (:ul
    "The distribution(s) are now specified as positional arguments,
     i.e. without \"-d\"."
    "Platform requirements are neither checked nor reported. The new
     \"platform-requirements\" command does that in a more sensible
     way."
    "It is no longer possible to generate jobs and reports in the same
     invocation. The new \"report\" command is responsible for
     generating reports. ")
   "Currently supported commands are:"
   (:ul
    (:verb "analyze                Analyze project repositories w.r.t. dependencies and meta-data.")
    (:verb "generate               Generate Jenkins jobs for a given distribution.")
    (:verb "help                   Print help either for all commands or for a given command.")
    (:verb "info-aspects           Print information about available aspects.")
    (:verb "info-variables         Print information about recognized variables.")
    (:verb "platform-requirements  Analyze system packages required on a given platform.")
    (:verb "report                 Generate one or more reports for given distribution(s).")
    (:verb "version                Print the version of this program and some components.")))

  (:incompatible-change
   "The configuration schema changed, affecting environment variables
    and the" (:file "build-generator.conf") "configuration file:"
   (:ul
    ("The old" (:code "general") "section is now
      called" (:cold "global") ":"
     (:ul
      (:verb "general.cache-directory → global.cache-directory")
      (:verb "general.temp-directory  → global.temp-directory")
      (:verb "general.num-processes   → global.num-processes")
      (:verb "general.progress-style  → global.progress-style")))
    ("The old" (:code "jenkis") "section no longer exists. Most of its
      options are now specific to the \"generate\" command:"
     (:ul
      (:verb "jenkins.base-uri             → commands.generate.base-uri")
      (:verb "jenkins.username             → commands.generate.username")
      (:verb "jenkins.password             → commands.generate.password")
      (:verb "jenkins.api-token            → commands.generate.api-token")
      (:verb "jenkins.delete-other         → commands.generate.delete-other?")
      (:verb "jenkins.delete-other-pattern → commands.generate.delete-other-pattern"))))
   "Setting the environment
    variable" (:code "BUILD_GENERATOR_CONFIG_DEBUG") "can help
    debugging configuration problems.")

  (:enhancement
   "Source locations are reported for missing project files included
    in distribution recipes.")

  (:bugfix
   "The" (:variable "recipe.maintainer") "variable is no longer
    inherited from distributions in projects.")

  (:enhancement
   "The" (:variable "build-job.disabled?") "variable now accepts the
    value" (:code "force-disabled") ".")

  (:enhancement
   "Upgrading cache entries written by an older generator version is
    no longer treated as an error.")

  (:enhancement
   "Analysis of projects with" (:code "ros_package ") "nature provides
    Maven artifacts in the" (:code "org.ros.rosjava_messages") "group.")

  (:enhancement
   "The analysis of repository committers has been improved.")

  (:enhancement
   "Support for the mercurial version control system has been
    improved.")

  (:enhancement
   "The new variable" (:variable "view.colums") "controls columns in
    created views."))

 (:release "0.20" "2018-03-02"

  (:enhancement
   "The" (:code "name") "property is now optional in all recipe
    kinds (It has already been optional in template recipes).")

  (:enhancement
   "In distributions, variable references are expanded in included
    project versions. However, the expression can only refer variables
    defined directly in the distribution.")

  (:enhancement
   "References to non-existent project versions are reported with
    source locations.")

  (:enhancement
   "When running interactively in a capable terminal, the \"one-line\"
    progress style is used by default.")

  (:bugfix
   "The" (:code "mps") "analysis no longer gets confused by symbolic
   links."))

 (:release "0.19" "2018-02-15"

  (:incompatible-change
   "Generated Jenkins jobs for projects with
    archive" (:variable "scm") "now respect the value of
    the" (:variable "sub-directory") " variable properly. Recipes that
    worked around this bug may have to be adjusted.")

  (:enhancement
   "Many recipe-related errors are now reported alongside an excerpt
    from the file highlighting relevant source locations.")

  (:enhancement
   "When generating Jenkins jobs, the ability to communicate with the
    specified Jenkins server is ensured before performing long-running
    operations such as project analyses, failing early in case there
    is a problem."))

 (:release "0.18" "2018-01-02"

  (:enhancement
   "Versions defined in the" (:code "versions") "section of project
    recipes can now overwrite more variables. In particular, the
    following variables now work as expected in version blocks:"
   (:ul
    (:variable "repository")
    (:variable "scm")
    (:variable "scm.username")
    (:variable "scm.password")
    (:variable "sub-directory")
    (:variable "branch")
    (:variable "tag")
    (:variable "commit")
    (:variable "directory")
    (:variable "natures")))

  (:enhancement
   "Jenkins' cross-site request forgery (CSRF) protection is now
    supported.")

  (:bugfix
   "Updating permissions in generated Jenkins jobs now works
    properly.")

  (:enhancement
   "The analysis of project licenses is now more robust and more
    efficient.")

  (:bugfix
   "The analysis of projects with" (:code "cmake") "nature handles
    sub-directories more robustly.")

  (:enhancement
   "A certain kind of Jetbrains MPS projects can now be analyzed using
    the" (:code "mps") "nature.")))
