UML Diagramming for Ikiwiki
===========================

Install
-------

Just run make, this will do a use-local install of the plugin.

Usage
-----

Do something like:

     [[!uml src="
      Alice -> Bob: Authentication Request
      Bob --> Alice: Authentication Response

      Alice -> Bob: Another authentication Request
      Alice <-- Bob: another authentication Response
    " ]]

For a WBS diagram:

    [[!wbs src="
    ' If you add links, use this to set the URL prefix:
    skinparam topurl https://url.of.my.wiki/

    * Business Process Modelling WBS
    ** Launch the project
    *** Complete Stakeholder Research
    *** Initial Implementation Plan
    ** Design phase
    *** Model of AsIs Processes Completed
    **** Model of AsIs Processes Completed1
    **** Model of AsIs Processes Completed2
    *** Measure AsIs performance metrics
    *** Identify Quick Wins
    ** Complete innovate phase
    ** [[OtherPage Link to other Page]]
    "]]

For the rest of PlantUML's syntax, read [the PlantUML Language Reference Guide](https://plantuml.com/en/guide)


