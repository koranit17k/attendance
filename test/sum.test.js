import { expect, test, describe } from 'vitest'
import { sum } from './sum.js'

const testCases = [
    { x: 0.1, y: 0.1, expected: 0.2 },
    { x: 0.1, y: 0.2, expected: 0.3 },
    { x: 0.1, y: 0.3, expected: 0.4 },
    { x: 0.1, y: 0.4, expected: 0.5 },
    { x: 0.1, y: 0.5, expected: 0.6 },
    { x: 0.1, y: 0.6, expected: 0.7 },
    { x: 0.1, y: 0.7, expected: 0.8 },
    { x: 0.1, y: 0.8, expected: 0.9 },
    { x: 0.1, y: 0.9, expected: 1.0 },
    { x: 0.2, y: 0.2, expected: 0.4 },
    { x: 0.2, y: 0.3, expected: 0.5 },
    { x: 0.2, y: 0.4, expected: 0.6 },
    { x: 0.2, y: 0.5, expected: 0.7 },
    { x: 0.2, y: 0.6, expected: 0.8 },
    { x: 0.2, y: 0.7, expected: 0.9 },
    { x: 0.2, y: 0.8, expected: 1.0 },
    { x: 0.2, y: 0.9, expected: 1.1 },
    { x: 0.3, y: 0.3, expected: 0.6 },
    { x: 0.3, y: 0.4, expected: 0.7 },
    { x: 0.3, y: 0.5, expected: 0.8 },
    { x: 0.3, y: 0.6, expected: 0.9 },
    { x: 0.3, y: 0.7, expected: 1.0 },
    { x: 0.3, y: 0.8, expected: 1.1 },
    { x: 0.3, y: 0.9, expected: 1.2 },
    { x: 0.4, y: 0.4, expected: 0.8 },
    { x: 0.4, y: 0.5, expected: 0.9 },
    { x: 0.4, y: 0.6, expected: 1.0 },
    { x: 0.4, y: 0.7, expected: 1.1 },
    { x: 0.4, y: 0.8, expected: 1.2 },
    { x: 0.4, y: 0.9, expected: 1.3 },
    { x: 0.5, y: 0.5, expected: 1.0 },
    { x: 0.5, y: 0.6, expected: 1.1 },
    { x: 0.5, y: 0.7, expected: 1.2 },
    { x: 0.5, y: 0.8, expected: 1.3 },
    { x: 0.5, y: 0.9, expected: 1.4 },
    { x: 0.6, y: 0.6, expected: 1.2 },
    { x: 0.6, y: 0.7, expected: 1.3 },
    { x: 0.6, y: 0.8, expected: 1.4 },
    { x: 0.6, y: 0.9, expected: 1.5 },
    { x: 0.7, y: 0.7, expected: 1.4 },
    { x: 0.7, y: 0.8, expected: 1.5 },
    { x: 0.7, y: 0.9, expected: 1.6 },
    { x: 0.8, y: 0.8, expected: 1.6 },
    { x: 0.8, y: 0.9, expected: 1.7 },
    { x: 0.9, y: 0.9, expected: 1.8 }
]

describe('Decimal Addition Tests (0.1 - 0.9)', () => {
    test.each(testCases)('adds $x + $y to equal $expected', ({ x, y, expected }) => {
        expect(sum(x, y)).toBe(expected)
    })
})
