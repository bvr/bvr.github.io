---
layout: post
title: Tracking number of push ups with Google Sheets
published: yes
tags:
  - google
  - sheets
  - gtg
---
[Grease the Groove (GTG)][1] is a system to become stronger with regular repetitions of an 
exercise of choice (typically a push up, pull up, squat or similar). The idea is to take a quick
break many times a day and do quick exercise.

I wanted to try it out, but quickly realized that without tracking I have no idea how much I actually 
managed to do. So I created quick spreadsheet in [Google Sheets][2]:

![GTG sheet](/img/gtg.png)

It shows day on each line. There is date including day name (in czech), then sum of given day. Following
fields are dedicated to number of repetitions done in a set. Total is visible on line 1. The spreadsheet works
nicely from both web browser and Google Sheets app on my Android phone.

As the table is for whole year, the list is quite long. As a little helper, I created quick macro to find current day.

```js
function goToCurrentDate() {
  var spreadsheet = SpreadsheetApp.getActive();
  var sheet = spreadsheet.getActiveSheet();
  var lastRow = sheet.getLastRow()
  var dates = sheet.getRange(1,1,lastRow).getValues();

  // find a row with current date or later
  var nowDate = new Date();
  for (var i in dates) {
    Logger.log(dates[i][0]);
    if (dates[i][0].valueOf() > nowDate.valueOf()) {
      Logger.log("found");

      // jump to first empty cell on the row
      var lastCol = sheet.getLastColumn();
      var row = sheet.getRange(i,3,1,lastCol - 3).getValues();
      for(var c in row[0]) {
        if(row[0][c] == "") {
          sheet.getRange(i, + c + 3).activate();
          break;
        }
      }
      break;
    }    
  }  
};
```

Within **Extensions**/**Macros**/**Manage macros** I configured it for hotkey `Ctrl+Alt+Shift+0` so it gets
easy to locate right row (and also column as it picks free empty space on the row).

[1]: https://www.artofmanliness.com/health-fitness/fitness/get-stronger-by-greasing-the-groove/
[2]: https://docs.google.com/spreadsheets
