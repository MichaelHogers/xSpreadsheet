HTMLWidgets.widget({

  name: 'RXSpreadsheet',

  type: 'output',

  factory: function(el, width, height) {

    var initialized = false;

    return {

      renderValue: function(message) {

        // render the widget
        if (!initialized){
          initialized = true;

          dataToLoad = message.message.flat();

          if (message.options !== null){
            optionsxspreadsheet = message.options;
          } else {
            optionsxspreadsheet = '{}';
          }


          debugger;

          var elementId = el.id;
          xspreadsheetloaded = x_spreadsheet('#' + elementId, optionsxspreadsheet)
          .change((cdata) => {
              var xspreadsheetdata = xspreadsheetloaded.getData();
              Shiny.setInputValue(elementId + '_RXSpreadsheetData:rxspreadsheetlist', xspreadsheetdata);
          })
          .loadData(dataToLoad);

          // initialise input binding, as otherwise binding will be NULL until a change is made
          var xspreadsheetdatainit = xspreadsheetloaded.getData();
          Shiny.setInputValue(elementId + '_RXSpreadsheetData:rxspreadsheetlist', xspreadsheetdatainit);

        }

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
