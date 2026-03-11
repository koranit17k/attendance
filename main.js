const BASE_URL = "http://192.168.30.162:8080/kxreport/"

function openWin() {
    return window.open("", "_blank")
}

function getFormDataAsJson() {
    const form = document.getElementById("form")
    const data = Object.fromEntries(new FormData(form).entries())
    return data
}

function getPDF() {
    console.log("testgetpdf 1")
    const data = getFormDataAsJson()
    const params = new URLSearchParams(data)
    const url = BASE_URL + "getPDF?" + params.toString()
    window.open(url, "_blank")
}

async function openPDF() {
    console.log("testopenpdf 2")
    const reportWindow = openWin()
    try {
        const data = getFormDataAsJson()

        const response = await fetch(BASE_URL + "openPDF", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(data),
        })

        if (!response.ok) {
            throw new Error(`Service call failed with status: ${response.status}`)
        }
        // reportWindow.location.href = BASE_URL + (await response.text())
        const blob = await response.blob();
        const blobUrl = URL.createObjectURL(blob);
        reportWindow.location.href = blobUrl;
    } catch (error) {
        console.error("Error calling FilePDF:", error)
        alert(`KX Report Error: ${error.message}`)

        if (reportWindow) {
            reportWindow.close()
        }
    }
}
