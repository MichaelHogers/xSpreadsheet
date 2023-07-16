// @ts-check
const { test, expect } = require('@playwright/test');

test('has title', async ({ page }) => {
  await page.goto('');

  // wait for canvas element to render
  await page.waitForSelector('canvas');

  ///////// Test cell interaction bindings

  // click in the page at 25%, 25% position
  await page.mouse.click(100, 100);
  // get value of tag with id 'cell_selected'
  // wait for #cell_selected to be non-empty
  await page.waitForSelector('#cell_selected');
  const selected = await page.$eval('#cell_selected', el => el.textContent);
  // expect value to be non-empty
  expect(selected).toBeTruthy();

  // set text
  await page.keyboard.type('Hello World!', { delay: 100 });

  // get value of tag with id 'cell_change'
  const changed = await page.$eval('#change_ts', el => el.textContent);
  // expect value to be non-empty
  expect(changed).toBeTruthy();

  // get value of tag with id 'cell_edited'
  const edited = await page.$eval('#cell_edited', el => el.textContent);
  // expect value to be non-empty
  expect(edited).toBeTruthy();

  // get value of tag with id 'cell_edited_value'
  // expect it to be 'Hello World!'
  const selectedValue = await page.$eval('#cell_edited_value', el => el.textContent);
  expect(selectedValue).toBe('Hello World!');

  ///////// End of test cell interaction bindings


  ///////// Test proxy functionality

  // "addSheet"
  await page.click('#addSheet');
  await page.click('#addSheet');

  // expect the ul tag with class x-spreadsheet-menu to contain
  // the text "new_sheet"
  await page.waitForSelector('.x-spreadsheet-menu');
  const menu = await page.$eval('.x-spreadsheet-menu', el => el.textContent);
  expect(menu).toContain('new_sheet');

  // "deleteSheet"
  // get number of sheets
  const sheets = await page.$eval('.x-spreadsheet-menu', el => el.childElementCount);
  // click on deleteSheet
  await page.click('#deleteSheet');
  // expect number of sheets to be less than before
  const sheets2 = await page.$eval('.x-spreadsheet-menu', el => el.childElementCount);
  expect(sheets2).toBeLessThan(sheets);

  // "deleteSheet" with sheetIndex
  await page.click('#deleteSheetIndex');
  // expect number of sheets to be smaller than sheets2
  // wait 100ms, otherwise the UI does not update in time
  await page.waitForTimeout(100);
  const sheets3 = await page.$eval('.x-spreadsheet-menu', el => el.childElementCount);
  expect(sheets3).toBeLessThan(sheets2);


  // "setCellText"
  await page.click('#setCellText');
  // expect a change event to be triggered, expect changed to be
  // different from previous value
  // wait 100ms, otherwise the UI does not update in time
  await page.waitForTimeout(100);
  const changed2 = await page.$eval('#change_ts', el => el.textContent);
  expect(changed2).not.toBe(changed);

  ///////// End of test proxy functionality

});
