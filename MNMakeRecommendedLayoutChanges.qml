/*
 * Copyright (C) 2025 Michael Norris
 *
 */

// this version requires MuseScore Studio 4.4 or later

import MuseScore 3.0
import QtQuick 2.9
import QtQuick.Controls 2.15
import Muse.UiComponents 1.0
import FileIO 3.0


MuseScore {
	version:  "1.0"
	description: "This plugin automatically makes recommended layout changes to the score, based on preferences curated by Michael Norris"
	menuPath: "Plugins.MNMakeRecommendedLayoutChanges";
	requiresScore: true
	title: "MN Make Recommended Layout Changes"
	id: mnmakerecommendedlayoutchanges
	thumbnailName: "MNMakeRecommendedLayoutChanges.png"	
	property var selectionArray: null
	property var firstMeasure: null
	property var numParts: 0
	property var isSoloScore: false
	property var inchesToMM: 25.4
	property var mmToInches: 0.039370079
	property var excerpts: null
	property var numExcerpts: 0
	property var amendedParts: false

  onRun: {
		if (!curScore) return;
		
		var finalMsg = '';
				
		// select all
		doCmd ("select-all");
		
		// get some variables
		firstMeasure = curScore.firstMeasure;
		var visibleParts = [];
		// ** calculate number of parts, but ignore hidden ones
		for (var i = 0; i < curScore.parts.length; i++) if (curScore.parts[i].show) visibleParts.push(curScore.parts[i]);
		numParts = visibleParts.length;
		isSoloScore = numParts == 1;
		excerpts = curScore.excerpts;
		numExcerpts = excerpts.length;
		if (numParts > 1 && numExcerpts < numParts) finalMsg = "Note that parts have not yet been created/opened, so I wasn’t able to alter the part settings.\nYou can do this by clicking ‘Parts’ then ’Open All’.\n\nOnce you have created and opened the parts, please run this again to alter the part settings.\nIgnore this message if you do not plan to create parts.";
		
		// REMOVE LAYOUT BREAKS
		removeLayoutBreaks();
		
		// SET ALL THE SPACING-RELATED SETTINGS
		setSpacing();
		
		// SET ALL THE OTHER STYLE SETTINGS
		setOtherStyleSettings();
		
		// FONT SETTINGS
		setFonts();
		
		// LAYOUT THE TITLE FRAME ON p. 1
		setTitleFrame();
		
		// SET PART SETTINGS
		setPartSettings();
		
		// CHANGE INSTRUMENT NAMES
		changeInstrumentNames();
		
		// SELECT NONE
		doCmd ('escape');
		
		var dialogMsg = '';
		if (amendedParts) {
			dialogMsg = '<p>Changes to the layout of the score and parts were made successfully.</p><p>Note that some changes may not be optimal, and further tweaks are likely to be required.</p>';
		} else {
			dialogMsg = '<p>Changes to the layout of the score were made successfully.</p><p>Note that some changes may not be optimal, and further tweaks are likely to be required.</p>';
			if (finalMsg != '') dialogMsg = dialogMsg + '<p>' + finalMsg + '</p>';
		}
		dialog.msg = dialogMsg;
		dialog.show();
		//restoreSelection();
	}
	
	function removeLayoutBreaks () {
		var currMeasure = firstMeasure;
		var breaks = [];
		while (currMeasure) {
			var elems = currMeasure.elements;
			for (var i = 0; i < elems.length; i ++) {
				if (elems[i].type == Element.LAYOUT_BREAK) {
					breaks.push(elems[i]);
				}
			}
			currMeasure = currMeasure.nextMeasure;
		}
		for (var i = 0; i < breaks.length; i++ ) deleteObj (breaks[i]);
	}
	
	function deleteObj (theElem) {
		curScore.startCmd ();
		removeElement (theElem);
		curScore.endCmd ();
	}
	
	function changeInstrumentNames () {
		// *** NEEDS API TO CHANGE TO BE WRITEABLE *** //
		/*
		var namesToChange = ["violin 1", "violins 1", "violin 2", "violins 2", "violas", "violas 1", "violas 2", "violoncellos", "cellos 1", "cellos 2", "contrabass", "contrabasses", "vlns. 1", "vln. 1", "vlns 1", "vln 1", "vn. 1", "vn 1", "vlns. 2", "vln. 2", "vlns 2", "vln 2", "vn. 2", "vlas. 1", "vla. 1", "vlas 1", "vla 1", "va. 1", "va 1", "vn 2", "vcs 1", "vcs. 1", "vc 1", "vcs. 1", "cellos 1", "vcs 2", "vcs. 2", "vc 2", "vcs. 2", "cellos 2", "vlas.", "vlas", "vcs.", "vcs", "cb", "cb.", "cbs", "cbs.", "db", "dbs", "db.", "dbs.","d.bs.","d.b.s"];
		
		var namesToChangeTo = ["Violin I", "Violin I", "Violin II", "Violin II", "Viola", "Viola I", "Viola II", "Cello", "Cello I", "Cello II", "Double Bass", "Double Bass", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. I", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Vn. II", "Va. I", "Va. I", "Va. I", "Va. I", "Va. I", "Va. I", "Va. II", "Va. II", "Va. II", "Va. II", "Va. II", "Va. II", "Cello I", "Cello I", "Cello I", "Cello I", "Cello I", "Cello II", "Cello II", "Cello II", "Cello II", "Cello II", "Viola", "Viola", "Cello", "Cello", "D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B.","D.B."];
		
		for (var i = 0; i < curScore.nstaves; i++) {
			var theStaff = curScore.staves[i];
			var fullStaffName = theStaff.part.longName.toLowerCase();
			var shortStaffName = theStaff.part.shortName.toLowerCase();
			var fullIndex = namesToChange.indexOf(fullStaffName);
			var shortIndex = namesToChange.indexOf(shortStaffName);
			var inst = theStaff.part.instrumentAtTick(0);
			if (fullIndex > -1 && fullIndex < namesToChangeTo.length) inst.longName = namesToChangeTo[fullIndex];
			if (shortIndex > -1 && shortIndex < namesToChangeTo.length) inst.shortName = namesToChangeTo[shortIndex];
		}*/
	}
	
	function setPartSettings () {
		
		if (isSoloScore || numExcerpts < numParts) return;
		var spatium = 6.8 / (4.0*inchesToMM*mscoreDPI);
		for (var i = 0; i < numExcerpts; i++) {
			var thePart = excerpts[i];			
			setPartSetting (thePart, "spatium",spatium);
			setPartSetting (thePart, "enableIndentationOnFirstSystem", 0);
			setPartSetting (thePart, "enableVerticalSpread", 1);
			setPartSetting (thePart, "minSystemSpread", 6);
			setPartSetting (thePart, "maxSystemSpread", 10);
			setPartSetting (thePart, "frameSystemDistance", 8);
			setPartSetting (thePart, "lastSystemFillLimit", 0);
			setPartSetting (thePart, "minNoteDistance", 1.3);
			setPartSetting (thePart, "createMultiMeasureRests", 1);
			setPartSetting (thePart, "minMMRestWidth", 18);
			setPartSetting (thePart, "partInstrumentFrameType", 1);
			setPartSetting (thePart, "partInstrumentFramePadding", 0.8);
		}
		amendedParts = true;
	}
	
	function setSpacing() {

		// change staff spacing
		// change min and max system distance
		setSetting ("minSystemDistance", 6.0);
		setSetting ("maxSystemDistance", 9.0);
		var lrMargin = 12.;
		var tbMargin = 15.;
		var lrIn = lrMargin*mmToInches;
		var tbIn = tbMargin*mmToInches;
		setSetting("pageEvenLeftMargin",lrIn);
		setSetting("pageOddLeftMargin",lrIn);
		setSetting("pageEvenTopMargin",tbIn);
		setSetting("pageOddTopMargin",tbIn);
		setSetting("pageEvenBottomMargin",tbIn);
		setSetting("pageOddBottomMargin",tbIn);
		var pageWidth = curScore.style.value("pageWidth") * inchesToMM;
		var pagePrintableWidth = (pageWidth - 2 * lrMargin) * mmToInches;
		setSetting("pagePrintableWidth",pagePrintableWidth);
		setSetting("staffLowerBorder",0);
		setSetting("frameSystemDistance",8);
		//setSetting("pagePrintableHeight",10/inchesToMM);
		
		// TO DO: SET SPATIUM
		// **** TEST 1B: CHECK STAFF SIZE ****)
		var staffSize = 6.8;
		if (numParts == 2) staffSize = 6.3;
		if (numParts == 3) staffSize = 6.2;
		if (numParts > 3 && numParts < 8) staffSize = 5.6 - Math.floor((numParts - 4) * 0.5) / 10.;
		if (numParts > 7) {
			staffSize = 5.2 - Math.floor((numParts - 8) * 0.5) / 10.;
			if (staffSize < 3.7) staffSize = 3.7;
		}
		var spatium = staffSize / 4.0;
		setSetting ("spatium",spatium/inchesToMM*mscoreDPI);
		
		// SET STAFF NAME VISIBILITY
		setSetting("hideInstrumentNameIfOneInstrument",1);
		setSetting("firstSystemInstNameVisibility",0);
		setSetting("subsSystemInstNameVisibility",1);
		var subsequentStaffNamesShouldBeHidden = numParts < 6;
		if (subsequentStaffNamesShouldBeHidden) {
			setSetting("subsSystemInstNameVisibility",2);
		} else {
			setSetting("subsSystemInstNameVisibility",1);
		}
		
		setSetting ("enableIndentationOnFirstSystem", !isSoloScore);
		
		// STAFF AND SYSTEM WIDTHS
		setSetting("enableVerticalSpread", 1);
		if (isSoloScore) {
			setSetting ("minSystemSpread", 6);
			setSetting ("maxSystemSpread", 14);
		} else {	
			setSetting("minSystemSpread", 12);
			setSetting("maxSystemSpread", 24);
		}
		setSetting("minStaffSpread", 5);
		if (isSoloScore) {
			setSetting("maxStaffSpread", 6);
		} else {
			setSetting("maxStaffSpread", 8);
		}
	}
	
	function setOtherStyleSettings() {
		// BAR SETTINGS
		setSetting("minMeasureWidth", isSoloScore ? 14.0 : 16.0);
		setSetting("measureSpacing",1.5);
		setSetting("barWidth",0.16);
		setSetting("showMeasureNumberOne", 0);
		setSetting("minNoteDistance", isSoloScore ? 1.1 : 0.6);
		setSetting("staffDistance", 5);
		
		// SLUR SETTINGS
		setSetting("slurEndWidth",0.06);
		setSetting("slurMidWidth",0.16);
		
		//setSetting("staffLowerBorder");
		setSetting("lastSystemFillLimit", 0);
		setSetting("crossMeasureValues",0);
		setSetting("tempoFontStyle", 1);
		setSetting("metronomeFontStyle", 0);
		setSetting("staffLineWidth",0.1);
	}
	
	function setFonts() {
		setSetting("tupletFontStyle", 2);
		setSetting("tupletFontSize", 11);
		setSetting("measureNumberFontSize", 8.5);
		setSetting("longInstrumentFontSize", 12);
		setSetting("shortInstrumentFontSize", 12);
		setSetting("partInstrumentFontSize", 12);
		setSetting("tempoFontSize", 13);
		setSetting("metronomeFontSize", 13);
		setSetting("pageNumberFontStyle",0);
		setSetting("pageNumberFontSize", 12);
		setSetting("musicalSymbolFont","Bravura");
		setSetting("musicalTextFont","Bravura Text");
		setSetting("titleFontSize",24);
		setSetting("subtitleFontSize",13);
		setSetting("composerFontSize",10);
		setSetting("expressionFontSize",12);
		setSetting("staffTextFontSize",12);
		setSetting("systemTextFontSize",12);
		
		var fontsToTimes = ["tupletFontFace", "lyricsOddFontFace", "lyricsEvenFontFace", "hairpinFontFace", "romanNumeralFontFace", "voltaFontFace", "stringNumberFontFace", "longInstrumentFontFace", "shortInstrumentFontFace","partInstrumentFontFace","expressionFontFace", "tempoFontFace", "tempoChangeFontFace", "metronomeFontFace", "measureNumberFontFace", "mmRestRangeFontFace", "systemTextFontFace", "staffTextFontFace", "pageNumberFontFace", "instrumentChangeFontFace"];
		for (var i = 0; i < fontsToTimes.length; i++) setSetting (fontsToTimes[i],"Times New Roman");
	}
	
	function setTitleFrame () {
		doCmd ("select-all");
		doCmd ("insert-vbox");
		var vbox = curScore.selection.elements[0];
		doCmd ("title-text");
		var tempText = curScore.selection.elements[0];
		doCmd ("select-similar");
		var elems = curScore.selection.elements;
		var firstPageNum = firstMeasure.parent.parent.pagenumber;
		var spatium = curScore.style.value("spatium")*25.4/mscoreDPI;
		var topbox = null;
		for (var i = 0; i < elems.length; i++) {
			var e = elems[i];
			if (!e.is(tempText)) {
				//logError ("Found text object "+e.text);
				var eSubtype = e.subtypeName();
				if (eSubtype == "Title" && getPageNumber(e) == firstPageNum) {
					e.align = Align.HCENTER;
					e.offsetY = 0;
					e.offsetX = 0.;
					topbox = e.parent;
				}
				if (eSubtype == "Subtitle" && getPageNumber(e) == firstPageNum) {	
					e.align = Align.HCENTER;
					e.offsetY = 10. / spatium;
					e.offsetX = 0.;
				}
				if (eSubtype == "Composer" && getPageNumber(e) == firstPageNum) {
					e.text = e.text.toUpperCase();
					e.align = Align.BOTTOM | Align.RIGHT;
					e.offsetY = 0;
					e.offsetX = 0;
				}
			}
		}
		if (vbox == null) {
			logError ("checkScoreText () — vbox was null");
		} else {
			deleteObj (vbox);
		}
		if (topbox != null) {
			
			curScore.startCmd ();
			topbox.autoscale = 0;
			topbox.boxHeight = 15;
			curScore.endCmd ();
		}
	}
	
	function doCmd (theCmd) {
		curScore.startCmd ();
		cmd (theCmd);
		curScore.endCmd ();
	}
	
	function setSetting (theSetting, theValue) {
		if (curScore.style.value(theSetting) == theValue) return;
		curScore.style.setValue(theSetting,theValue);
	}
	
	function setPartSetting (thePart, theSetting, theValue) {
		if (thePart.partScore.style.value(theSetting) == theValue) return;
		thePart.partScore.style.setValue(theSetting,theValue);
	}
	
	function getPageNumber (e) {
		var p = e.parent;
		var ptype = null;
		if (p != null) ptype = p.type;
		while (p && ptype != Element.PAGE) {
			p = p.parent;
			if (p != null) ptype = p.type;
		}
		if (p != null) {
			return p.pagenumber;
		} else {
			return 0;
		}
	}
	
	StyledDialogView {
			id: dialog
			title: "CHECK COMPLETED"
			contentHeight: 232
			contentWidth: 456
			property var msg: ""
		
			Text {
				id: theText
				width: parent.width-40
				x: 20
				y: 20
		
				text: "MN MAKE RECOMMENDED LAYOUT CHANGES"
				font.bold: true
				font.pointSize: 18
			}
			
			Rectangle {
				x:20
				width: parent.width-45
				y:45
				height: 1
				color: "black"
			}
		
			ScrollView {
				id: view
				x: 20
				y: 60
				height: parent.height-100
				width: parent.width-40
				leftInset: 0
				leftPadding: 0
				ScrollBar.vertical.policy: ScrollBar.AsNeeded
				TextArea {
					height: parent.height
					textFormat: Text.RichText
					text: dialog.msg
					wrapMode: TextEdit.Wrap
					leftInset: 0
					leftPadding: 0
					readOnly: true
				}
			}
		
			ButtonBox {
				anchors {
					horizontalCenter: parent.horizontalCenter
					bottom: parent.bottom
					margins: 10
				}
				buttons: [ ButtonBoxModel.Ok ]
				navigationPanel.section: dialog.navigationSection
				onStandardButtonClicked: function(buttonId) {
					if (buttonId === ButtonBoxModel.Ok) {
						dialog.close()
					}
				}
			}
		}
	}
