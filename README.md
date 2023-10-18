# PlantUML diagram generator for Salesforce orgs

SalesforcePlantUML is a native Force.com application that renders UML diagrams from your orgs metadata. Currently it supports ERD diagrams from your SObjects. 
The diagrams are rendered by an external declarative UML service / library called [PlantUML](http://plantuml.sourceforge.net/).

> PlantUML is a free and open source UML tool for drawing UML diagrams from a simple and human readable text description. It ca be used as a stand-alone application or can be used from many different IDEs.[1] Dependencies for PlantUML are a Java virtual machine and an installation of Graphviz.
To create the UML diagrams, PlantUML has a meta-language defined that allows the diagram creator to describe the UML as a series of text statements which the graphics engine translates into standard UML notation. The graphics engine is written in Java and is distributed in both JAR and source code form. [2]

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

## /apex/erdCreator page ##

This page render a UML class diagram that show standard and custom SObjects, their fields for a given permission set and related metadata (e.g. pages and triggers)

1.  Open page YOUR_ORG_URL/apex/erdCreator
2.  Select SObjects (If you choose too many or too complex classes you might get Limit errors.)
3   Choose some options
4.  Wait! (IMPORTANT as the main work is done in Javascript and on a very slow server)

and for SObjects including field permissions and related metadata (pages, trigger,...)

![Page /apex/erdCreator](https://raw.github.com/rsoesemann/SalesforcePlantUML/master/resources/plantuml4force_erd.png)

## Third-party Code ##

This app makes use of third-party components also hosted on GitHub:

- [Apex-Select-Option-Sorting](https://github.com/abhinavguptas/Apex-Select-Option-Sorting), an Apex sort utility class for SelectOptions
- [Multiselect Component](https://github.com/metadaddy-sfdc/Visualforce-Multiselect-Picklist), a Multiselect Picklist Visualforce Component
- [PlantUML Javascript bridge](http://plantuml.sourceforge.net/codejavascript2.html) A javascript Deflate algorithm to create URL to call the plantuml.com image server
