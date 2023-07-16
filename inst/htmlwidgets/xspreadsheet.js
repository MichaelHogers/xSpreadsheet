window.rxspreadsheet = null;

HTMLWidgets.widget({

    name: 'xspreadsheet',
    type: 'output',

    factory: function(el, width, height) {

      return {

        renderValue: function(message) {

            window.rxspreadsheet = window.rxspreadsheet || {};

            if (window.rxspreadsheet[el.id] === undefined) {

              // process message.options.view.height
              // and message.options.view.width
              // if they are not defined, then set
              // each to () => $('#' + id).height()
              // and () => $('#' + id).width()
              // which are sensible defaults that will
              // scale nicely
              // Ensure message.options exists
              message.options = message.options || {};

              // Ensure message.options.view exists
              message.options.view = message.options.view || {};

              // Set sensible defaults for height and width if they are not defined
              if (message.options.view.height === undefined) {
                message.options.view.height = () => $('#' + el.id).height();
              }
              if (message.options.view.width === undefined) {
                message.options.view.width = () => $('#' + el.id).width();
              }
              window.rxspreadsheet[el.id] = null;
              window.rxspreadsheet[el.id] =
                x_spreadsheet('#' + el.id, message.options)
                  .loadData(
                    message.data
                  ).change(data => {
                    Shiny.setInputValue(
                      el.id + "_change",
                      // timestamp UTC
                      new Date().toISOString()
                    );
                  })

                // + 1 indexing to avoid confusion in R
                window.rxspreadsheet[el.id].on(
                    'cell-selected',
                    (cell, ri, ci) => {
                      Shiny.setInputValue(
                        el.id + "_cell_selected",
                        {"row": ri + 1, "cell": ci + 1, "value": cell},
                        ({priority: "event"})
                      );
                  }).on('cells-selected', (cell, { sri, sci, eri, eci }) => {
                    Shiny.setInputValue(
                      el.id + "_cells_selected",
                      {"start_row": sri + 1, "start_cell": sci + 1,
                      "end_row": eri + 1,  "end_cell": eci + 1},
                      {priority: "event"}
                    );
                  }).on('cell-edited', (cell, ri, ci) => {
                    Shiny.setInputValue(
                      el.id + "_cell_edited",
                      {"row": ri + 1, "cell": ci + 1, "value": cell},
                      {priority: "event"}
                    );
                  })
            } else {
              // if it already exists, reload the data only
              window.rxspreadsheet[el.id].loadData(
                message.data
              );
            }
        },

        resize: function(width, height) {

        }
      };
    }
  });


// proxy support, so x-spreadsheet API calls
// can be made from R via invokeProxy and dependencies
Shiny.addCustomMessageHandler("xspreadsheet-calls", function(data) {
  var id = data.id;
  var el2 = document.getElementById(id);

  if (!el2.classList.contains("xspreadsheet")) {
    console.log("Couldn't find x-spreadsheet with id " + id +
    ", missing xspreadsheet class");
    return;
  }

  // available methods on the x-spreadsheet API
  // ### R server side -> x-spreadsheet client side
  // addSheet(name, active)
  // reRender (refresh the entire table)
  // loadData(data) (reload the data)
  // change(callback), page operations or data changes
  // cellText(ri, ci, text, sheetIndex) (set text)

  // DOES NOT WORK, issue in x-spreadsheet ?
  // locale('zh-cn'/'en'/'nl'/'de'), change localisation
  // deleteSheet (delete the current sheet)

  // getData, retrieve all data and keep all formatting
  //    and table settings

  if (data.call.method === "addSheet") {
    rxspreadsheet[id].addSheet(
      data.call.args.name,
      data.call.args.active
    ).reRender();
  } else if (data.call.method === "reRender") {
    rxspreadsheet[id].reRender();
  } else if (data.call.method === "deleteSheet") {
    // deleteSheet() does not work
    // rxspreadsheet[id].deleteSheet().reRender();

    // instead we use javascript and simulate clicking
    // the delete button of the active sheet

    // if sheetIndex is not defined, then delete the active sheet
    // otherwise delete the sheet with index sheetIndex
    if (data.call.args.sheetIndex === undefined || data.call.args.sheetIndex === null) {
      var selector = "#" + id + " > div > div.x-spreadsheet-bottombar > ul > li.active";
    } else {
      // + 2, css nth-child is 1 indexed and the first child is irrelevant
      var selector = "#" + id + " > div > div.x-spreadsheet-bottombar > ul > li:nth-child(" +
      data.call.args.sheetIndex + 2 + ")";
    }

    // this right clicks the active sheet
    var contextMenuEvent = new MouseEvent(
      'contextmenu', {
        bubbles: true,
        cancelable: true,
        view: window
      }
    );
    document.querySelector(
      selector
    ).dispatchEvent(contextMenuEvent);

    // find the button with "Delete" and click it
    var deleteTag = document.querySelectorAll(
      "#" + id + " > div > div.x-spreadsheet-bottombar > div > div"
    );

    deleteTag.forEach((element) => {
      if (element.textContent.includes("Delete")) {
        element.click();
      }
    });

  } else if (data.call.method === "loadData") {
    rxspreadsheet[id].loadData(data.call.args.data);
  } else if (data.call.method === "cellText") {
    rxspreadsheet[id].cellText(
      ri = data.call.args.rowIndex,
      ci = data.call.args.colIndex,
      text = data.call.args.text,
      data.call.args.sheetIndex
    ).reRender();
    // rerender, this is necessary for the cellText
    // call to be reflected in the UI

    if (data.call.args.triggerChange) {
      Shiny.setInputValue(
        id + "_change",
        // timestamp UTC
        new Date().toISOString()
      );
    }

  } else if (data.call.method === "getData") {
    // convert JSON to a string
    // so Shiny does not try to parse it
    // TO DO: check if this is still necessary, bit hacky
    // is there a input handler that prevents parsing?
    Shiny.setInputValue(
      id + "_data",
      JSON.stringify(
        rxspreadsheet[id].getData()
      ),
      {priority: "event"}
    )
  } else if (data.call.method === "cell") {
    Shiny.setInputValue(
      id + "_cell",
      rxspreadsheet[id].cell(
        data.call.args.ri,
        data.call.args.ci,
        data.call.args.sheetIndex
      ),
      {priority: "event"}
    )
  } else if (data.call.method === "cellStyle") {
    Shiny.setInputValue(
      id + "_cell_style",
      rxspreadsheet[id].cellStyle(
        data.call.args.ri,
        data.call.args.ci,
        data.call.args.sheetIndex
      ),
      {priority: "event"}
    )
  } else {
    console.log("Unknown method " + data.call.method);
  }

  // ### x-spreadsheet client side -> R server side
  // cell(ri, ci, sheetIndex) (get content)
  // cellStyle(ri, ci, sheetIndex) (get style)
  // getData()
  // on(eventName, callback) binding event


});
