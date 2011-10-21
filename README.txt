
XProc E-Book Processor v1.0 by @grtjn
-------------------------------------

This application converts XML files to electronic publication files. It is designed to accept multiple input formats, and allow them to be composed (in mixed order as well) into a single electronic publication of a format of choice. By employing a more or less three stage process, the application is capable of applying many kinds of enrichments, regardless of chosen input and output formats. The application uses XProc and related XML technologies only to do the processing. This with the exception of some IO handling (using XMLCalabash extensions), and epub validation (using epubcheck called via p:exec).

The application has been written entirely for the Code Challenge by XML Holland (http://www.xmlholland.nl/node/770), but has conceptually grown far beyond the requirements of the contest. The goal of the contest was just to create an ePub out of a given TEI document, but this application has been designed to do so in a highly configurable way, and to accept multiple input formats, and in future allow creation of output formats other than ePub.

Feature list
------------

- Supported input formats:
	- (X)HTML (taken as is)
	- MS Word 2003 XML (very, very limited)
	- TEI 2 (reasonable coverage)
- Supported output formats:
	- ePub (tested against Adobe Digital Editions)
- Easy plugging of new input formats (just add some xsls to the source tree)
- Designed to make addition of new output formats relatively easy
- Various enrichments:
	- Insertion of table of contents
	- Insertion of index of spatial and smallcaps words
	- Insertion of notes page, collecting all footnotes of the publication
	- Insertion of list of illustrations
	- Insertion of list of tables
	- All of them include hyperlinks to the appropriate pages and the exact position on them
	- Footnotes have bidirectional links
- Reconstruction of section nesting, based on heading levels
- Advanced pagination based on page-breaks (from original input, or from generated content)
- Auto-pagenumbering for generated content (Roman for front, Number for body, Alpha for back)
- Advanced control over publication composition using templates
	- Separate control for metadata, front, main, and back matter
	- Mixing of input formats
	- Insertion of generated content
	- Layout options
- Built-in mechanism for supporting different stylings
	- Application comes with three styles: default, dbnl, medieval
	- Control of required styling files, like CSS, images, fonts, etc
	- More layout options
- Logging control (debug, verbose, run.log)
- Prepared DTD catalog, with support for the TEI 2 dtd (quicker and enables working offline)

Given more time this list would have been much longer. See BUGS.txt for some of the features that were on the nomination list.

Installation and usage
----------------------

Please refer to INSTALL.txt.

Licence
-------

This application is licensed with GPL. Please refer to NOTICE.txt and GPL.txt for further details.

Contact
-------
XProc E-Book Processor is maintained by Geert Josten, <geert.josten@gmail.com>.
