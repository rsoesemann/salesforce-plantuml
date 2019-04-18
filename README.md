# PlantUML diagram generator for Salesforce orgs [![Codacy Badge](https://api.codacy.com/project/badge/Grade/1eabf2af4fa64f229816eb01b450a7d2)](https://www.codacy.com/app/rsoesemann/salesforce-plantuml?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=rsoesemann/salesforce-plantuml&amp;utm_campaign=Badge_Grade)

[![Deploy](https://deploy-to-sfdx.com/dist/assets/images/DeployToSFDX.svg)](https://deploy-to-sfdx.com)
sfdx<a href="https://githubsfdeploy.herokuapp.com?owner=rsoesemann&repo=salesforce-plantuml">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

SalesforcePlantUML is a native Force.com application that renders UML class diagrams for a given set of Apex classes or SObjects. 
The diagrams are rendered by an external declarative UML service / library called [PlantUML](http://plantuml.sourceforge.net/).

> PlantUML is a free and open source UML tool for drawing UML diagrams from a simple and human readable text description. It ca be used as a stand-alone application or can be used from many different IDEs.[1] Dependencies for PlantUML are a Java virtual machine and an installation of Graphviz.
To create the UML diagrams, PlantUML has a meta-language defined that allows the diagram creator to describe the UML as a series of text statements which the graphics engine translates into standard UML notation. The graphics engine is written in Java and is distributed in both JAR and source code form. [2]

All the information required to render such diagrams is extracted via Apex code and very ugly ;) and unstable Regular Expressions. 
This should definitely be replace by code that uses the new [Tooling API](http://www.salesforce.com/us/developer/docs/api_toolingpre/index.htm). 
Feel free to collaborate.

## /apex/classDiagramCreator page ##

This page renders a UML class diagram that show classes, their attribute, methods, inner classes and relations to other classes.
It also calculates basic complexity metrics like LOC and Cyclomatic complexity.

1.  Open page YOUR_ORG_URL/apex/classDiagramCreator
2.  Select classes (If you choose too many or too complex classes you might get Limit errors.)
3   Choose some options
4.  Wait! (IMPORTANT as the main work is done in Javascript and on a very slow server)

> ![Page /apex/classDiagramCreator](https://raw.github.com/rsoesemann/SalesforcePlantUML/master/resources/plantuml4force_class.png)

## /apex/erdCreator page ##

This page render a UML class diagram that show standard and custom SObjects, their fields for a given permission set and related metadata (e.g. pages and triggers)

1.  Open page YOUR_ORG_URL/apex/erdCreator
2.  Select SObjects (If you choose too many or too complex classes you might get Limit errors.)
3   Choose some options
4.  Wait! (IMPORTANT as the main work is done in Javascript and on a very slow server)

and for SObjects including field permissions and related metadata (pages, trigger,...)

> ![Page /apex/erdCreator](https://raw.github.com/rsoesemann/SalesforcePlantUML/master/resources/plantuml4force_erd.png)

## Third-party Code ##

This app makes use of third-party components also hosted on GitHub:

- [Apex-Select-Option-Sorting](https://github.com/abhinavguptas/Apex-Select-Option-Sorting), an Apex sort utility class for SelectOptions
- [Multiselect Component](https://github.com/metadaddy-sfdc/Visualforce-Multiselect-Picklist), a Multiselect Picklist Visualforce Component
- [PlantUML Javascript bridge](http://plantuml.sourceforge.net/codejavascript2.html) A javascript Deflate algorithm to create URL to call the plantuml.com image server
