// I learned about validation here: http://msconline.maconstate.edu/Tutorials/JSDHTML/JSDHTML15/jsdhtml15-05.htm

// lower limit is zero
function validate_range(upper)
{
    code = event.which;
    // backspace is ok
    if (code == 8) {return true;}
    // tab is ok
    if (code == 9) {return true;}
    // zero is code 48
    if (code >= 48 && code <= 48+upper) {return true;}
    return false;
}

// booleans are denoted with "y" or "n" (upper- or lower-case is acceptable)
function validate_boolean()
{
    code = event.which;
    // backspace is ok
    if (code == 8) {return true;}
    // tab is ok
    if (code == 9) {return true;}
    var s = String.fromCharCode(code)
        if (s == "Y" || s == 'y' || s == "N" || s == 'n') {return true;}
    return false;
}

function validate () {
	red = parseInt(document.getElementById('results_LeveeTouchingRed').value);
	green = parseInt(document.getElementById('results_LeveeTouchingGreen').value);
	alert (red + green);
	if (red + green > 8)
	{
		alert('Red + Green Levees must be <= 8');
		return false;
	}
	
	moneyResearch = document.getElementById('results_MoneyInResearchArea').value;
	moneyUnderground = document.getElementById('results_MoneyInUndergroundReservoir').value;
	if (moneyResearch =='Y' && moneyUnderground == 'Y')
	{
		alert('Yellow money ball must be in either Research Area or Underground, not both');
		return false;
	}
	
	bearUpright = document.getElementById('results_BearUpright').value;
	bearSleeping = document.getElementById('results_BearSleeping').value;
	if (bearUpright =='Y' && bearSleeping == 'Y')
	{
		alert('Bear can be either Upright or Sleeping, not both!');
		return false;
	}	
	
	robotResearch = document.getElementById('results_RobotInResearch').value;
	robotYellow = document.getElementById('results_RobotInYellowGrid').value;
	if (robotResearch =='Y' && robotResearch == 'Y')
	{
		alert('Robot may finish in either Research Area or Yellow Grid Area, not both!');
		return false;
	}
	
	return true;
}