import express from 'express';
import fs from 'fs';
import createClassListTemplate from "./templates/classlist";
import createStudentReceiptTemplate from "./templates/studentreceipts";

const app = express();
app.use(express.json());

const port = 6000;
app.listen(port, () => {
  console.log(`The sample PDF app is running on port ${port}.`);
});


app.post("/classlist", async (req, res) => {
    // Calling the template render func with dynamic data
    const data = JSON.parse(req.body.data);
    const cname = data.details.replace(/ /g, "_");
    let currentyear = data.year.replace("/","-");
    const result = await createClassListTemplate(data);

    if(!fs.existsSync(`../be/uploads/classlists/${currentyear}`)) {
      fs.mkdirSync(`../be/uploads/classlists/${currentyear}`, { recursive: true });
    }
  
    // Streaming our resulting pdf back to the user
    let f = result.pipe(fs.createWriteStream(`../be/uploads/classlists/${currentyear}/${cname}.pdf`));
    f.on('finish', function() {
      res.send('{"error":false}');
    });
    f.on('error', function(err) {
      console.log(err);
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