import { expect, test } from 'vitest'
import { sum } from './sum.js'

test('adds 1 + 2 to equal 3', () => {
  expect(sum(1, 2)).toBe(3)
  console.log('guy')
})
test('adds 0.2 + 0.2 to equal 0.4', () => {
  expect(sum(0.2, 0.2)).toBe(0.4)
})
