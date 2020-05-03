HTMLWidgets.widget({

  name: 'RXSpreadsheet',

  type: 'output',

  factory: function(el, width, height) {

    var rxspreadsheet = null;

    return {

      renderValue: function(message) {
debugger;
        if (rxspreadsheet === null) {
          // initialise object & render the widget
          var rxspreadsheetData = message.data[0];
          var rxspreadsheetOptions = message.options == undefined? '{}': message.options;

          rxspreadsheet = x_spreadsheet('#' + el.id, rxspreadsheetOptions)
          .loadData(rxspreadsheetData)
          .change(function() {
            $(el).trigger('change.rxspreadsheet');
          });

          el.rxspreadsheet = rxspreadsheet;
          // initialise
          $(el).trigger('change.rxspreadsheet');
        }

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});


var rxspreadsheetBinding = new Shiny.InputBinding();

// step ii
$.extend(rxspreadsheetBinding, {

  find: function(scope) {
    return $(scope).find(".RXSpreadsheet");
  },

  getId: function(el) {

    return el.id + '_RXSpreadsheetData';
  },

  getValue: function(el) {
    if (el.rxspreadsheet != undefined) {
      return el.rxspreadsheet.getData();
    } else {
      return null;
    }

  },

  subscribe: function(el, callback) {
    $(el).on("change.rxspreadsheet", function(e) {
      callback(true);
    });
  },

  unsubscribe: function(el) {
    $(el).off(".rxspreadsheet");
  },

  getRatePolicy: function() {

    return {policy: 'debounce',
            delay: 500
    };
  },

  getType: function(el) {
    return "rxspreadsheetlist";
 }

});

// step iii
Shiny.inputBindings.register(rxspreadsheetBinding);
