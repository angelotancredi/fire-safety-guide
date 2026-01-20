const admin = require('firebase-admin');
const fs = require('fs');
const { parse } = require('csv-parse/sync');
const path = require('path');

async function uploadData() {
    try {
        const serviceAccountPath = path.join(__dirname, 'service_account.json');
        const csvPath = path.join(__dirname, 'equipment_data.csv');

        if (!fs.existsSync(serviceAccountPath)) {
            console.error('Error: "service_account.json" not found. Please provide your Firebase Service Account Key.');
            return;
        }

        if (!fs.existsSync(csvPath)) {
            console.error('Error: "equipment_data.csv" not found.');
            return;
        }

        const serviceAccount = require(serviceAccountPath);

        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });

        const db = admin.firestore();
        const csvContent = fs.readFileSync(csvPath, 'utf8');
        const records = parse(csvContent, {
            columns: true,
            skip_empty_lines: true
        });

        console.log(`Loaded ${records.length} rows from CSV.`);

        let successCount = 0;
        let errorCount = 0;

        for (let i = 0; i < records.length; i++) {
            const row = records[i];
            try {
                const data = {
                    item_name: row.item_name,
                    standard: row.standard,
                    law_basis: row.law_basis,
                    category: row.category
                };

                // Use item_name as document ID
                await db.collection('equipment_codes').doc(row.item_name).set(data);
                console.log(`Successfully uploaded: ${row.item_name}`);
                successCount++;
            } catch (err) {
                console.error(`Error at row ${i + 2}: ${err.message}`);
                errorCount++;
            }
        }

        console.log('\nUpload Summary:');
        console.log(`Total rows processed: ${records.length}`);
        console.log(`Successful: ${successCount}`);
        console.log(`Failed: ${errorCount}`);

    } catch (err) {
        console.error('Global error:', err.message);
    }
}

uploadData();
