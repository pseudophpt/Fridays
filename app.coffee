request = require 'request'
request = request.defaults {jar: true}

jsdom = require 'jsdom'
{ JSDOM } = jsdom

notifier = require 'node-notifier'

settings = require './settings'

districtID = settings.districtID
username = settings.username
password = settings.password
interval = settings.interval

district = "https://fridaystudentportal.com/" + districtID + "/"
gradebook = "https://fridaystudentportal.com/portal/index.cfm?f=gradebook.cfm"
login = "https://fridaystudentportal.com/portal/security/login.cfm"
validate = "https://fridaystudentportal.com/portal/security/validateStudent.cfm"
base = "https://fridaystudentportal.com"

grades = [];

crawl = ->
  requestDistrict()

  setTimeout(crawl, 60000 * interval)

  return

# Chain of http requests

requestDistrict = ->
  request {
    method : 'GET'
    uri : district
  }, requestLogin


requestLogin = (err, data, body) ->
  request {
    method : 'GET'
    uri : login
  }, requestValidate

requestValidate = (err, data, body) ->
  request {
    method : 'POST'
    uri : validate
    form :
      username : username
      password : password
  }, requestGradebook

requestGradebook = (err, data, body) ->
  request {
    method : 'GET'
    uri : gradebook
  }, domParse




domParse = (err, data, body) ->
  dom = new JSDOM body

  coursesTableContainer = dom.window.document.querySelector 'div.table-responsive.table-responsive-cardtable'
  coursesTable = coursesTableContainer.children[0]
  courses = coursesTable.children[1]

  courseNo = 0

  for course in courses.children
    grade = course.children[1].innerHTML
    gradeFormatted = grade.split /\t+/g
    gradeFormatted = gradeFormatted[2]
    gradeFormatted = gradeFormatted.split ' \n'
    gradeFormatted = gradeFormatted[0]

    courseSection = course.children[0]
    courseLink = courseSection.children[0]
    courseTitle = courseLink.innerHTML.trim()

    gradeNumber = parseInt gradeFormatted

    if grades[courseNo] isnt NaN and grades[courseNo]? and grades[courseNo] isnt gradeNumber
      gradeChange = gradeNumber - grades[courseNo]
      gradeChange = if gradeChange > 0 then '+' + gradeChange else '-' + Math.abs(gradeChange)
      notifier.notify courseTitle + ': ' + gradeNumber + ' (' + gradeChange + ')'

    grades[courseNo] = gradeNumber
    courseNo += 1

  return


crawl()
###var dom = new JSDOM(body);

var tableContainer = dom.window.document.querySelector('div.table-responsive.table-responsive-cardtable');
var table = tableContainer.children[0];
var tableBody = table.children[1];
var trs = tableBody.children;

for (var i = 0; i < trs.length; i ++) {
  var tr = trs[i];

var gradeElement = tr.children[1];
var grade = gradeElement.innerHTML;
var gradeFormatted = grade.split(/\t+/g)[2].split(' \n')[0];

var gradeNumber = parseInt(gradeFormatted);

var course = tr.children[0];
var courseLink = course.children[0]
var courseTitle = courseLink.innerHTML;
var courseURI = courseLink.href;

If grade changed
if (grades[i] != undefined && !isNaN(gradeNumber)) {
  if (grades[i] != gradeNumber) {
    var change = (gradeNumber > grades[i]) ?  "risen" : "dropped";
    var difference = Math.abs(gradeNumber - grades[i]);
    updates += ('Your grade in ' + courseTitle + ' has ' + change + ' ' + difference + ' points to a(n) ' + gradeNumber + '\n');
}
}

 Update grade
grades[i] = gradeNumber;
}###

# Loop

