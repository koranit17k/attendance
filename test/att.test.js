import { describe, test, expect, beforeAll, afterAll } from "vitest"
import mysql from "mysql2/promise"

const DB_CONFIG = {
    host: "localhost",
    user: "koranit",
    password: "oeviivog",
    database: "payroll",
}

const EMP_CODE = "99999"
const TEST_MONTH = "3000-01"

const testCases = [
    {
        id: 1,
        scenario: "Normal 1",
        scans: ["07:52:00", "12:12:00", "13:12:00", "17:05:00"],
        exp: { work: 480, lunch: 60, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 2,
        scenario: "Normal 2",
        scans: ["07:50:00", "12:14:00", "12:45:00", "17:30:00"],
        exp: { work: 480, lunch: 31, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 3,
        scenario: "Normal 3",
        scans: ["07:50:00", "12:14:00", "12:45:00", "16:30:00"],
        exp: { work: 450, lunch: 31, ot: 0, late1: 0, late2: 30 },
    },
    {
        id: 4,
        scenario: "OT Night 1",
        scans: ["06:54:00", "12:32:00", "12:54:00", "17:31:00", "21:12:00"],
        exp: { work: 480, lunch: 22, ot: 192, late1: 0, late2: 0 },
    },
    {
        id: 5,
        scenario: "OT Night 2",
        scans: ["07:32:00", "12:10:00", "12:55:00", "21:10:00"],
        exp: { work: 480, lunch: 45, ot: 190, late1: 0, late2: 0 },
    },
    {
        id: 6,
        scenario: "OT Night 3",
        scans: ["12:12:00", "12:55:00", "21:30:00"],
        exp: { work: 240, lunch: 43, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 7,
        scenario: "OT Early",
        scans: ["07:35:00", "12:05:00", "12:57:00", "02:02:00"],
        exp: { work: 480, lunch: 52, ot: 482, late1: 0, late2: 0 },
    },
    {
        id: 8,
        scenario: "Missing Lunch 1",
        scans: ["07:38:00", "17:03:00"],
        exp: { work: 240, lunch: 0, ot: 0, late1: 0, late2: 240 },
    },
    {
        id: 9,
        scenario: "Missing Lunch 2",
        scans: ["07:50:00", "12:34:00", "17:05:00"],
        exp: { work: 360, lunch: 0, ot: 0, late1: 0, late2: 120 },
    },
    {
        id: 10,
        scenario: "Missing Lunch 3",
        scans: ["07:12:00", "14:39:00", "17:32:00"],
        exp: { work: 360, lunch: 0, ot: 0, late1: 0, late2: 120 },
    },
    {
        id: 11,
        scenario: "morning+OT",
        scans: ["07:44:00", "12:01:00", "12:49:00", "20:31:00"],
        exp: { work: 480, lunch: 48, ot: 151, late1: 0, late2: 0 },
    },
    {
        id: 12,
        scenario: "morning+MLunch+OT 1",
        scans: ["07:39:00", "20:11:00"],
        exp: { work: 240, lunch: 0, ot: 131, late1: 0, late2: 240 },
    },
    {
        id: 13,
        scenario: "morning+MLunch+OT 2",
        scans: ["07:23:00", "12:22:00", "20:58:00"],
        exp: { work: 360, lunch: 0, ot: 178, late1: 0, late2: 120 },
    },
    {
        id: 14,
        scenario: "morning+MLunch+OT 3",
        scans: ["07:23:00", "14:02:00", "20:05:00"],
        exp: { work: 360, lunch: 0, ot: 125, late1: 0, late2: 120 },
    },
    {
        id: 15,
        scenario: "morning+MLunch+early",
        scans: ["07:21:00", "02:08:00"],
        exp: { work: 240, lunch: 0, ot: 488, late1: 0, late2: 240 },
    },
    {
        id: 16,
        scenario: "Half Day Morning 1",
        scans: ["07:41:00", "11:45:00"],
        exp: { work: 225, lunch: 0, ot: 0, late1: 0, late2: 15 },
    },
    {
        id: 17,
        scenario: "Half Day Morning 2",
        scans: ["07:41:00", "12:23:00", "12:51:00"],
        exp: { work: 240, lunch: 28, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 18,
        scenario: "Half Day Afternoon 1",
        scans: ["13:10:00", "17:05:00"],
        exp: { work: 230, lunch: 0, ot: 0, late1: 0, late2: 10 },
    },
    {
        id: 19,
        scenario: "Half Day Afternoon 2",
        scans: ["12:20:00", "12:50:00", "16:50:00"],
        exp: { work: 230, lunch: 30, ot: 0, late1: 0, late2: 10 },
    },
    {
        id: 20,
        scenario: "Late Morning",
        scans: ["08:20:00", "12:10:00", "13:01:00", "16:55:00"],
        exp: { work: 455, lunch: 51, ot: 0, late1: 20, late2: 5 },
    },
    {
        id: 21,
        scenario: "Late Morning Half",
        scans: ["08:30:00", "12:20:00"],
        exp: { work: 210, lunch: 0, ot: 0, late1: 30, late2: 0 },
    },
    {
        id: 22,
        scenario: "Late Lunch",
        scans: ["07:30:00", "12:01:00", "13:23:00", "17:03:00"],
        exp: { work: 458, lunch: 82, ot: 0, late1: 0, late2: 22 },
    },
    {
        id: 23,
        scenario: "Spam Morning",
        scans: ["07:50:00", "08:02:00", "08:05:00", "16:55:00"],
        exp: { work: 230, lunch: 0, ot: 0, late1: 5, late2: 245 },
    },
    {
        id: 24,
        scenario: "Spam Lunch Out",
        scans: ["07:30:00", "11:54:00", "12:05:00", "12:10:00", "17:09:00"],
        exp: { work: 480, lunch: 16, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 25,
        scenario: "Absent 1",
        scans: ["07:31:00"],
        exp: { work: 0, lunch: 0, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 26,
        scenario: "Absent 2",
        scans: ["17:30:00"],
        exp: { work: 0, lunch: 0, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 27,
        scenario: "Absent 3",
        scans: ["17:30:00", "20:02:00"],
        exp: { work: 0, lunch: 0, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 28,
        scenario: "Absent 4",
        scans: ["20:02:00"],
        exp: { work: 0, lunch: 0, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 29,
        scenario: "Absent 5",
        scans: ["12:01:00", "13:01:00"],
        exp: { work: 0, lunch: 60, ot: 0, late1: 0, late2: 0 },
    },
    {
        id: 30,
        scenario: "Absent 6",
        scans: ["11:15:00"],
        exp: { work: 0, lunch: 0, ot: 0, late1: 0, late2: 0 },
    },
]

describe("Attendance System Verification (Year 3000)", () => {
    let connection
    // ประกาศชื่อ function cleanup
    const cleanup = async () => {
        const [year, month] = TEST_MONTH.split("-")
        await connection.execute(
            `DELETE FROM timecard WHERE scanCode = ? AND YEAR(scanAt) = ? AND MONTH(scanAt) = ?`,
            [EMP_CODE, year, month],
        )
        await connection.execute(
            `DELETE a FROM attendance a JOIN employee e ON a.comCode = e.comCode AND a.empCode = e.empCode WHERE e.scanCode = ? AND YEAR(a.dateAt) = ? AND MONTH(a.dateAt) = ?`,
            [EMP_CODE, year, month],
        )
    }

    beforeAll(async () => {
        connection = await mysql.createConnection(DB_CONFIG)

        // 1. Cleanup
        await cleanup()

        // 2. Batch Seed all scenarios
        const allScans = []
        testCases.forEach((tc) => {
            const dateStr = `${TEST_MONTH}-${tc.id.toString().padStart(2, "0")}`
            tc.scans.forEach((s) => {
                // If time is before 06:00, it's the next day (early case)
                const hour = parseInt(s.split(":")[0])
                let scanDate = dateStr
                if (hour < 6) {
                    const nextDay = tc.id + 1
                    scanDate = `${TEST_MONTH}-${nextDay.toString().padStart(2, "0")}`
                }
                allScans.push([EMP_CODE, `${scanDate} ${s}`])
            })
        })

        if (allScans.length > 0) {
            await connection.query(`INSERT INTO timecard (scanCode, scanAt) VALUES ?`, [allScans])
        }

        // 3. Run Procedures
        await connection.query(`CALL runTimeCard('${TEST_MONTH}-01')`)
        await connection.query(`CALL runAttendance('${TEST_MONTH}-01')`)
    })

    afterAll(async () => {
        await cleanup()
        if (connection) await connection.end()
    })

    test.each(testCases)("Scenario $id: $scenario", async ({ id, scenario, exp }) => {
        const dateStr = `${TEST_MONTH}-${id.toString().padStart(2, "0")}`
        const [rows] = await connection.query(
            `SELECT * FROM attendance a JOIN employee e ON a.comCode = e.comCode AND a.empCode = e.empCode WHERE e.scanCode = ? AND a.dateAt = ?`,
            [EMP_CODE, dateStr],
        )
        const actual = rows[0]

        const getVal = (val) => (val === null || val === undefined ? 0 : Number(val))

        const work = getVal(actual?.work_minutes)
        const lunch = getVal(actual?.lunch_minutes)
        const ot = getVal(actual?.ot_total_minutes)
        const late1 = getVal(actual?.late_morning_minutes)
        const late2 = getVal(actual?.late_lunch_minutes)

        const msg = (field, expected, got) =>
            `Scenario ${id}: ${scenario} - ${field} expected ${expected} but got ${got}`

        expect(work, msg("Work Minutes", exp.work, work)).toBe(exp.work)
        expect(lunch, msg("Lunch Minutes", exp.lunch, lunch)).toBe(exp.lunch)
        expect(ot, msg("OT Minutes", exp.ot, ot)).toBe(exp.ot)
        expect(late1, msg("Late 1 Minutes", exp.late1, late1)).toBe(exp.late1)
        expect(late2, msg("Late 2 Minutes", exp.late2, late2)).toBe(exp.late2)
    })
})
