// (C) Wolfgang Huber 2010-2011

// Script parameters - these are set up by R in the function 'writeReport' when copying the 
//   template for this script from arrayQualityMetrics/inst/scripts into the report.

var highlightInitial = [ false, false, false, false, false, false, false, false, true, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, true, false, false, false, false, true, false, true, false, false, false, false, false ];
var arrayMetadata    = [ [ "1", "GSM2934481_2102-N.CEL", "1" ], [ "2", "GSM2934482_2102-T.CEL", "2" ], [ "3", "GSM2934483_2110-N.CEL", "3" ], [ "4", "GSM2934484_2110-T.CEL", "4" ], [ "5", "GSM2934485_2146-N.CEL", "5" ], [ "6", "GSM2934486_2146-T.CEL", "6" ], [ "7", "GSM2934487_2181-N.CEL", "7" ], [ "8", "GSM2934488_2181-T.CEL", "8" ], [ "9", "GSM2934489_2190-N.CEL", "9" ], [ "10", "GSM2934490_2190-T.CEL", "10" ], [ "11", "GSM2934491_2280-N.CEL", "11" ], [ "12", "GSM2934492_2280-T.CEL", "12" ], [ "13", "GSM2934493_2297-N.CEL", "13" ], [ "14", "GSM2934494_2297-T.CEL", "14" ], [ "15", "GSM2934495_2353-N.CEL", "15" ], [ "16", "GSM2934496_2353-T.CEL", "16" ], [ "17", "GSM2934497_2365-N.CEL", "17" ], [ "18", "GSM2934498_2365-T.CEL", "18" ], [ "19", "GSM2934499_2397-N.CEL", "19" ], [ "20", "GSM2934500_2397-T.CEL", "20" ], [ "21", "GSM2934501_2451-N.CEL", "21" ], [ "22", "GSM2934502_2451-T.CEL", "22" ], [ "23", "GSM2934503_2454-N.CEL", "23" ], [ "24", "GSM2934504_2454-T.CEL", "24" ], [ "25", "GSM2934505_2706-N.CEL", "25" ], [ "26", "GSM2934506_2706-T.CEL", "26" ], [ "27", "GSM2934507_2780-N.CEL", "27" ], [ "28", "GSM2934508_2780-T.CEL", "28" ], [ "29", "GSM2934509_2910-N.CEL", "29" ], [ "30", "GSM2934510_2910-T.CEL", "30" ], [ "31", "GSM2934511_2917-N.CEL", "31" ], [ "32", "GSM2934512_2917-T.CEL", "32" ], [ "33", "GSM2934513_2943-N.CEL", "33" ], [ "34", "GSM2934514_2943-T.CEL", "34" ], [ "35", "GSM2934515_2972-N.CEL", "35" ], [ "36", "GSM2934516_2972-T.CEL", "36" ], [ "37", "GSM2934517_2985-N.CEL", "37" ], [ "38", "GSM2934518_2985-T.CEL", "38" ], [ "39", "GSM2934519_3156-N.CEL", "39" ], [ "40", "GSM2934520_3156-T.CEL", "40" ], [ "41", "GSM2934521_3159-N.CEL", "41" ], [ "42", "GSM2934522_3159-T.CEL", "42" ], [ "43", "GSM2934523_3197-N.CEL", "43" ], [ "44", "GSM2934524_3197-T.CEL", "44" ], [ "45", "GSM2934525_3232-N.CEL", "45" ], [ "46", "GSM2934526_3232-T.CEL", "46" ], [ "47", "GSM2934527_3297-N.CEL", "47" ], [ "48", "GSM2934528_3297-T.CEL", "48" ], [ "49", "GSM2934529_3355-N.CEL", "49" ], [ "50", "GSM2934530_3355-T.CEL", "50" ] ];
var svgObjectNames   = [ "pca", "dens" ];

var cssText = ["stroke-width:1; stroke-opacity:0.4",
               "stroke-width:3; stroke-opacity:1" ];

// Global variables - these are set up below by 'reportinit'
var tables;             // array of all the associated ('tooltips') tables on the page
var checkboxes;         // the checkboxes
var ssrules;


function reportinit() 
{
 
    var a, i, status;

    /*--------find checkboxes and set them to start values------*/
    checkboxes = document.getElementsByName("ReportObjectCheckBoxes");
    if(checkboxes.length != highlightInitial.length)
	throw new Error("checkboxes.length=" + checkboxes.length + "  !=  "
                        + " highlightInitial.length="+ highlightInitial.length);
    
    /*--------find associated tables and cache their locations------*/
    tables = new Array(svgObjectNames.length);
    for(i=0; i<tables.length; i++) 
    {
        tables[i] = safeGetElementById("Tab:"+svgObjectNames[i]);
    }

    /*------- style sheet rules ---------*/
    var ss = document.styleSheets[0];
    ssrules = ss.cssRules ? ss.cssRules : ss.rules; 

    /*------- checkboxes[a] is (expected to be) of class HTMLInputElement ---*/
    for(a=0; a<checkboxes.length; a++)
    {
	checkboxes[a].checked = highlightInitial[a];
        status = checkboxes[a].checked; 
        setReportObj(a+1, status, false);
    }

}


function safeGetElementById(id)
{
    res = document.getElementById(id);
    if(res == null)
        throw new Error("Id '"+ id + "' not found.");
    return(res)
}

/*------------------------------------------------------------
   Highlighting of Report Objects 
 ---------------------------------------------------------------*/
function setReportObj(reportObjId, status, doTable)
{
    var i, j, plotObjIds, selector;

    if(doTable) {
	for(i=0; i<svgObjectNames.length; i++) {
	    showTipTable(i, reportObjId);
	} 
    }

    /* This works in Chrome 10, ssrules will be null; we use getElementsByClassName and loop over them */
    if(ssrules == null) {
	elements = document.getElementsByClassName("aqm" + reportObjId); 
	for(i=0; i<elements.length; i++) {
	    elements[i].style.cssText = cssText[0+status];
	}
    } else {
    /* This works in Firefox 4 */
    for(i=0; i<ssrules.length; i++) {
        if (ssrules[i].selectorText == (".aqm" + reportObjId)) {
		ssrules[i].style.cssText = cssText[0+status];
		break;
	    }
	}
    }

}

/*------------------------------------------------------------
   Display of the Metadata Table
  ------------------------------------------------------------*/
function showTipTable(tableIndex, reportObjId)
{
    var rows = tables[tableIndex].rows;
    var a = reportObjId - 1;

    if(rows.length != arrayMetadata[a].length)
	throw new Error("rows.length=" + rows.length+"  !=  arrayMetadata[array].length=" + arrayMetadata[a].length);

    for(i=0; i<rows.length; i++) 
 	rows[i].cells[1].innerHTML = arrayMetadata[a][i];
}

function hideTipTable(tableIndex)
{
    var rows = tables[tableIndex].rows;

    for(i=0; i<rows.length; i++) 
 	rows[i].cells[1].innerHTML = "";
}


/*------------------------------------------------------------
  From module 'name' (e.g. 'density'), find numeric index in the 
  'svgObjectNames' array.
  ------------------------------------------------------------*/
function getIndexFromName(name) 
{
    var i;
    for(i=0; i<svgObjectNames.length; i++)
        if(svgObjectNames[i] == name)
	    return i;

    throw new Error("Did not find '" + name + "'.");
}


/*------------------------------------------------------------
  SVG plot object callbacks
  ------------------------------------------------------------*/
function plotObjRespond(what, reportObjId, name)
{

    var a, i, status;

    switch(what) {
    case "show":
	i = getIndexFromName(name);
	showTipTable(i, reportObjId);
	break;
    case "hide":
	i = getIndexFromName(name);
	hideTipTable(i);
	break;
    case "click":
        a = reportObjId - 1;
	status = !checkboxes[a].checked;
	checkboxes[a].checked = status;
	setReportObj(reportObjId, status, true);
	break;
    default:
	throw new Error("Invalid 'what': "+what)
    }
}

/*------------------------------------------------------------
  checkboxes 'onchange' event
------------------------------------------------------------*/
function checkboxEvent(reportObjId)
{
    var a = reportObjId - 1;
    var status = checkboxes[a].checked;
    setReportObj(reportObjId, status, true);
}


/*------------------------------------------------------------
  toggle visibility
------------------------------------------------------------*/
function toggle(id){
  var head = safeGetElementById(id + "-h");
  var body = safeGetElementById(id + "-b");
  var hdtxt = head.innerHTML;
  var dsp;
  switch(body.style.display){
    case 'none':
      dsp = 'block';
      hdtxt = '-' + hdtxt.substr(1);
      break;
    case 'block':
      dsp = 'none';
      hdtxt = '+' + hdtxt.substr(1);
      break;
  }  
  body.style.display = dsp;
  head.innerHTML = hdtxt;
}
