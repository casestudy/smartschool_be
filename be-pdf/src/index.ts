import express from 'express';
import fs from 'fs';
import createClassListTemplate from "./templates/classlist";
import createStudentReceiptTemplate from "./templates/studentreceipts";

const app = express();
app.use(express.json());

const port = 5000;
app.listen(port, () => {
  console.log(`The sample PDF app is running on port ${port}.`);
});


app.post("/classlist", async (req, res) => {
    // Calling the template render func with dynamic data
    const data = JSON.parse(req.body.data);
    const result = await createClassListTemplate(data);
  
    // Streaming our resulting pdf back to the user
    let f = result.pipe(fs.createWriteStream(`../be/uploads/classlists/${data.details}.pdf`));
    f.on('finish', function() {
      res.send('{"error":false}');
    });
    f.on('error', function() {
      res.send('{"error": true, "msg":"Could not write stream"}');
    });    
});

app.post("/studentreceipts", async (req, res) => {
    // Calling the template render func with dynamic data
    const data = JSON.parse(req.body.data);
    let currentyear = data.year.replace("/","-");
    let sname = `${data.details[0].surname} ${data.details[0].othernames}`;

    const result = await createStudentReceiptTemplate(data);
  
    // Streaming our resulting pdf back to the user
    if(!fs.existsSync(`../be/uploads/studentreceipts/${currentyear}`)) {
      fs.mkdirSync(`../be/uploads/studentreceipts/${currentyear}`, { recursive: true });
    }

    let f = result.pipe(fs.createWriteStream(`../be/uploads/studentreceipts/${currentyear}/${sname}.pdf`));
    f.on('finish', function() {
      res.send('{"error":false}');
    });
    f.on('error', function() {
      res.send('{"error": true, "msg":"Could not write stream"}');
    });    
});

app.all('/', (req, res) => {
	res.send('{"result":"Test"}');
	return;
});