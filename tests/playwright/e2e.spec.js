// @ts-check
const { test, expect } = require('@playwright/test');

test('has title', async ({ page }) => {
  await page.goto('');

  // wait for canvas element to render
  await page.waitForSelector('canvas');

  // click in the page at 25%, 25% position
  await page.mouse.click(100, 100);
  // get value of tag with id 'cell_selected'
  const selected = await page.$eval('#cell_selected', el => el.textContent);
  // expect value to be non-empty
  expect(selected).toBeTruthy();

  // set text
  await page.keyboard.type('Hello World!');

  // wait for 1 second
  // otherwise the typed value is picked up only partially
  await page.waitForTimeout(1000);

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


});
