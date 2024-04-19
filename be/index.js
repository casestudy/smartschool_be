import express from 'express';
import bodyParser from 'body-parser';
import config from './config.js';
import utils from './utils.js';
import cors from 'cors';
import mysql from 'mysql';
import pkg from 'pg';
import multer from 'multer';
import fs from 'fs';
import csv from 'csvtojson';
import axios from 'axios';
import nodemailer from 'nodemailer';
import crypto from 'crypto';
import Heads from './Heads.json' assert { type: "json" };

const { Client } = pkg;

// routes 

const port = config.service.port || 3000;

// Set up the express app
const app = express();

app.use(cors()); //Allows request from an external url different from that of the server

const conndetails = {
    user: 'fabricefemencha',
    host: 'localhost', //ffedfd70407b
    database: 'shopman_pos',
    password: 'Azemchop1988.',
    port: 5432,
}

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.all('/', (req, res) => {
	res.send(utils.sendErrorMessage("",453,"Missing operation"));
	return;
});
// Get login a user
app.post('/login', (req, res) => { 
	const con = new Client(conndetails);
	con.connect(); 

	let username = '';
	let password = '';
	let orgid = '';
	let magik = '';
	let mid = '';
	let midtype = '';
	let locale = '';

	if(req.query.hasOwnProperty('username') || req.body.hasOwnProperty('username')) {
		username = req.query.hasOwnProperty('username') ? req.query["username"] : req.body["username"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- username"));
		return;
	}

	if(req.query.hasOwnProperty('password') || req.body.hasOwnProperty('password')) {
		password = req.query.hasOwnProperty('password') ? req.query["password"] : req.body["password"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- password"));
		return;
	}

	if(req.query.hasOwnProperty('orgid') || req.body.hasOwnProperty('orgid')) {
		const oid = req.query.hasOwnProperty('orgid') ? req.query["orgid"] : req.body["orgid"] ;

		if(parseInt(Number(oid)) == oid) {
			orgid = oid
		} else {
			res.send(utils.sendErrorMessage("",453,"Value was not an integer -- orgid"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- orgid"));
		return;
	}

	if(req.query.hasOwnProperty('magik') || req.body.hasOwnProperty('magik')) {
		magik = req.query.hasOwnProperty('magik') ? req.query["magik"] : req.body["magik"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- magik"));
		return;
	}

	if(req.query.hasOwnProperty('mid') || req.body.hasOwnProperty('mid')) {
		mid = req.query.hasOwnProperty('mid') ? req.query["mid"] : req.body["mid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- mid"));
		return;
	}

	if(req.query.hasOwnProperty('midtype') || req.body.hasOwnProperty('midtype')) {
		midtype = req.query.hasOwnProperty('midtype') ? req.query["midtype"] : req.body["midtype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- midtype"));
		return ;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const remotehost = '41.202.219.255';
  
	const query = 'SELECT loginuser('+ mysql.escape(username) +','+ mysql.escape(orgid) + ',' + mysql.escape(password) + ',' + mysql.escape(mid) + ',' + mysql.escape(midtype) + ',' + mysql.escape(remotehost) + ',' + mysql.escape(magik) + ',' + mysql.escape(locale) +')';
	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("login",err.code,err.message));
		} else {
			res.send(rows.rows[0]["loginuser"]);
			con.end();
		}
	});
});

// Logs out a user
app.post('/logout', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let utype = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	const query = 'CALL logoutuser('+ mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("logout",err.code,err.message));
		} else {
			res.send(utils.sendSuccessMessage());
			con.end();
		}
	});

});

// Logs out a user
app.post('/chpwd', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let username = '';
	let orgid = '';
	let emailaddress = '';
	let password = '';

	if(req.query.hasOwnProperty('username') || req.body.hasOwnProperty('username')) {
		username = req.query.hasOwnProperty('username') ? req.query["username"] : req.body["username"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- username"));
		return;
	}

	if(req.query.hasOwnProperty('orgid') || req.body.hasOwnProperty('orgid')) {
		const oid = req.query.hasOwnProperty('orgid') ? req.query["orgid"] : req.body["orgid"] ;

		if(parseInt(Number(oid)) == oid) {
			orgid = oid
		} else {
			res.send(utils.sendErrorMessage("",453,"Value was not an integer -- orgid"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- orgid"));
		return;
	}

	if(req.query.hasOwnProperty('emailaddress') || req.body.hasOwnProperty('emailaddress')) {
		emailaddress = req.query.hasOwnProperty('emailaddress') ? req.query["emailaddress"] : req.body["emailaddress"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- emailaddress"));
		return;
	}

	if(req.query.hasOwnProperty('password') || req.body.hasOwnProperty('password')) {
		password = req.query.hasOwnProperty('password') ? req.query["password"] : req.body["password"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- password"));
		return;
	}

	const query = 'CALL chusrpwd('+ mysql.escape(username)+','+mysql.escape(orgid)+','+mysql.escape(emailaddress)+','+mysql.escape(password)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("chusrpwd",err.code,err.message));
		} else {
			res.send(utils.sendSuccessMessage());
			con.end();
		}
	});

});

// Get all users
app.all('/getallusers', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let utype = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('utype') || req.body.hasOwnProperty('utype')) {
		utype = req.query.hasOwnProperty('utype') ? req.query["utype"] : req.body["utype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- utype"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	const query = 'SELECT getusers('+ mysql.escape(utype) +','+ mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getallusers",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getusers"]);
			con.end();
		}
	});

});

// Add a user
app.all('/createuser', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let utype = '';
	let locale = '';
	let username = '';
	let surname = '';
	let othernames = '';
	let emailaddress = '';
	let phonenumber = '';
	let gender = '';
	let dob = '';
	let position = '';
	let onidle = '';
	let localee = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('utype') || req.body.hasOwnProperty('utype')) {
		utype = req.query.hasOwnProperty('utype') ? req.query["utype"] : req.body["utype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- utype"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	if(req.query.hasOwnProperty('username') || req.body.hasOwnProperty('username')) {
		username = req.query.hasOwnProperty('username') ? req.query["username"] : req.body["username"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- username"));
		return;
	}

	if(req.query.hasOwnProperty('surname') || req.body.hasOwnProperty('surname')) {
		surname = req.query.hasOwnProperty('surname') ? req.query["surname"] : req.body["surname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- surname"));
		return;
	}

	if(req.query.hasOwnProperty('othernames') || req.body.hasOwnProperty('othernames')) {
		othernames = req.query.hasOwnProperty('othernames') ? req.query["othernames"] : req.body["othernames"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- othernames"));
		return;
	}

	if(req.query.hasOwnProperty('emailaddress') || req.body.hasOwnProperty('emailaddress')) {
		emailaddress = req.query.hasOwnProperty('emailaddress') ? req.query["emailaddress"] : req.body["emailaddress"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- emailaddress"));
		return;
	}

	if(req.query.hasOwnProperty('phonenumber') || req.body.hasOwnProperty('phonenumber')) {
		phonenumber = req.query.hasOwnProperty('phonenumber') ? req.query["phonenumber"] : req.body["phonenumber"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- phonenumber"));
		return;
	}

	if(req.query.hasOwnProperty('gender') || req.body.hasOwnProperty('gender')) {
		gender = req.query.hasOwnProperty('gender') ? req.query["gender"] : req.body["gender"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- gender"));
		return;
	}

	if(req.query.hasOwnProperty('dob') || req.body.hasOwnProperty('dob')) {
		dob = req.query.hasOwnProperty('dob') ? req.query["dob"] : req.body["dob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- dob"));
		return;
	}

	if(req.query.hasOwnProperty('position') || req.body.hasOwnProperty('position')) {
		position = req.query.hasOwnProperty('position') ? req.query["position"] : req.body["position"] ;
	} else {
		if (utype == 'teacher') {
			position = '';
		} else {
			res.send(utils.sendErrorMessage("",453,"Missing required parameter -- position"));
			return;
		}
	}

	if(req.query.hasOwnProperty('onidle') || req.body.hasOwnProperty('onidle')) {
		onidle = req.query.hasOwnProperty('onidle') ? req.query["onidle"] : req.body["onidle"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- onidle"));
		return;
	}

	if(req.query.hasOwnProperty('localee') || req.body.hasOwnProperty('localee')) {
		localee = req.query.hasOwnProperty('localee') ? req.query["localee"] : req.body["localee"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- localee"));
		return;
	}

	const query = 'SELECT adduser('+ mysql.escape(username) +','+ mysql.escape(surname)+','+
					mysql.escape(othernames)+','+mysql.escape(emailaddress)+','+
					mysql.escape(phonenumber)+','+mysql.escape(position)+','+
					mysql.escape(utype)+','+mysql.escape(dob)+','+
					mysql.escape(gender)+','+mysql.escape(onidle)+','+
					mysql.escape(locale)+','+mysql.escape(connid)+','+mysql.escape(localee)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("adduser",err.code,err.message));
		} else {
			res.send(rows.rows[0]["adduser"]);
			con.end();
		}
	});

});

// Modify a user
app.all('/modifyuser', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let userid = '';
	let connid = '';
	let utype = '';
	let locale = '';
	let surname = '';
	let othernames = '';
	let emailaddress = '';
	let phonenumber = '';
	let gender = '';
	let dob = '';
	let position = '';
	let onidle = '';
	let localee = '';

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('utype') || req.body.hasOwnProperty('utype')) {
		utype = req.query.hasOwnProperty('utype') ? req.query["utype"] : req.body["utype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- utype"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	if(req.query.hasOwnProperty('surname') || req.body.hasOwnProperty('surname')) {
		surname = req.query.hasOwnProperty('surname') ? req.query["surname"] : req.body["surname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- surname"));
		return;
	}

	if(req.query.hasOwnProperty('othernames') || req.body.hasOwnProperty('othernames')) {
		othernames = req.query.hasOwnProperty('othernames') ? req.query["othernames"] : req.body["othernames"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- othernames"));
		return;
	}

	if(req.query.hasOwnProperty('emailaddress') || req.body.hasOwnProperty('emailaddress')) {
		emailaddress = req.query.hasOwnProperty('emailaddress') ? req.query["emailaddress"] : req.body["emailaddress"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- emailaddress"));
		return;
	}

	if(req.query.hasOwnProperty('phonenumber') || req.body.hasOwnProperty('phonenumber')) {
		phonenumber = req.query.hasOwnProperty('phonenumber') ? req.query["phonenumber"] : req.body["phonenumber"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- phonenumber"));
		return;
	}

	if(req.query.hasOwnProperty('gender') || req.body.hasOwnProperty('gender')) {
		gender = req.query.hasOwnProperty('gender') ? req.query["gender"] : req.body["gender"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- gender"));
		return;
	}

	if(req.query.hasOwnProperty('dob') || req.body.hasOwnProperty('dob')) {
		dob = req.query.hasOwnProperty('dob') ? req.query["dob"] : req.body["dob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- dob"));
		return;
	}

	if(req.query.hasOwnProperty('position') || req.body.hasOwnProperty('position')) {
		position = req.query.hasOwnProperty('position') ? req.query["position"] : req.body["position"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- position"));
		return;
	}

	if(req.query.hasOwnProperty('onidle') || req.body.hasOwnProperty('onidle')) {
		onidle = req.query.hasOwnProperty('onidle') ? req.query["onidle"] : req.body["onidle"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- onidle"));
		return;
	}

	if(req.query.hasOwnProperty('localee') || req.body.hasOwnProperty('localee')) {
		localee = req.query.hasOwnProperty('localee') ? req.query["localee"] : req.body["localee"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- localee"));
		return;
	}

	const query = 'SELECT edituser('+ mysql.escape(userid) +','+ mysql.escape(surname)+','+
					mysql.escape(othernames)+','+mysql.escape(emailaddress)+','+
					mysql.escape(phonenumber)+','+mysql.escape(position)+','+
					mysql.escape(utype)+','+mysql.escape(dob)+','+
					mysql.escape(gender)+','+mysql.escape(onidle)+','+
					mysql.escape(locale)+','+mysql.escape(connid)+','+mysql.escape(localee)+')';
 
	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("edituser",err.code,err.message));
		} else {
			res.send(rows.rows[0]["edituser"]);
			con.end();
		}
	});
});

// Get user roles
app.all('/getuserroles', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let userid = '';
	let connid = '';

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	const query = 'SELECT getuserroles('+ mysql.escape(userid) + ',' + mysql.escape(connid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getuserroles",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getuserroles"]);
			con.end();
		}
	});
});

// Get all roles
app.all('/getallroles', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	const query = 'SELECT getallroles(' + mysql.escape(connid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getallroles",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getallroles"]);
			con.end();
		}
	});
});

// Create new role
app.all('/createrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let name = '';
	let desc = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('rname') || req.body.hasOwnProperty('rname')) {
		name = req.query.hasOwnProperty('rname') ? req.query["rname"] : req.body["rname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- rname"));
		return;
	}

	if(req.query.hasOwnProperty('descript') || req.body.hasOwnProperty('descript')) {
		desc = req.query.hasOwnProperty('descript') ? req.query["descript"] : req.body["descript"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descript"));
		return;
	}

	const query = 'SELECT createrole(' + mysql.escape(connid) + ',' + mysql.escape(name) + ',' + mysql.escape(desc) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createrole"]);
			con.end();
		}
	});
});

// Modify role
app.all('/updaterole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';
	let name = '';
	let desc = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('rname') || req.body.hasOwnProperty('rname')) {
		name = req.query.hasOwnProperty('rname') ? req.query["rname"] : req.body["rname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- rname"));
		return;
	}

	if(req.query.hasOwnProperty('descript') || req.body.hasOwnProperty('descript')) {
		desc = req.query.hasOwnProperty('descript') ? req.query["descript"] : req.body["descript"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descript"));
		return;
	}

	const query = 'SELECT updaterole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ',' + mysql.escape(name) + ',' + mysql.escape(desc) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("updaterole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["updaterole"]);
			con.end();
		}
	});
});

// Modify role
app.all('/removerole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	const query = 'SELECT removerole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removerole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removerole"]);
			con.end();
		}
	});
});

// Modify role
app.all('/getroleperms', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	const query = 'SELECT getrolepermissions(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getrolepermissions",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getrolepermissions"]);
			con.end();
		}
	});
});

// Modify role
app.all('/removeprivsfromrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';
	let privs = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('privs') || req.body.hasOwnProperty('privs')) {
		privs = req.query.hasOwnProperty('privs') ? req.query["privs"] : req.body["privs"] ;
		if(privs.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- privs"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- privs"));
		return;
	}

	const query = 'SELECT removeprivilegesfromrole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ',\'' + JSON.stringify(privs) + '\')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removeprivilegesfromrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removeprivilegesfromrole"]);
			con.end();
		}
	});
});

// Fetch permission types
app.all('/getpermtypes', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	const query = 'SELECT getpermissiontypes(' + mysql.escape(connid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getpermissiontypes",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getpermissiontypes"]);
			con.end();
		}
	});
});

// Add privilege to role
app.all('/addprivtorole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';
	let priv = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('priv') || req.body.hasOwnProperty('priv')) {
		priv = req.query.hasOwnProperty('priv') ? req.query["priv"] : req.body["priv"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- priv"));
		return;
	}

	const query = 'SELECT addprivilegetorole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ',' + mysql.escape(priv) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addaddprivilegetorole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addprivilegetorole"]);
			con.end();
		}
	});
});

// Add privileges to role
app.all('/addprivstorole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';
	let privs = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('privs') || req.body.hasOwnProperty('privs')) {
		privs = req.query.hasOwnProperty('privs') ? req.query["privs"] : req.body["privs"] ;
		if(privs.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- privs"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- priv"));
		return;
	}

	const query = 'SELECT addprivilegestorole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ',\'' + JSON.stringify(privs) + '\')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addaddprivilegestorole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addprivilegestorole"]);
			con.end();
		}
	});
});

// Remove privilege to role
app.all('/removeprivfromrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';
	let priv = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('priv') || req.body.hasOwnProperty('priv')) {
		priv = req.query.hasOwnProperty('priv') ? req.query["priv"] : req.body["priv"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- priv"));
		return;
	}

	const query = 'SELECT removeprivilegefromrole(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ',' + mysql.escape(priv) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removeprivilegefromrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removeprivilegefromrole"]);
			con.end();
		}
	});
});

// Get role sub roles
app.all('/getsubroles', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let roleid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	const query = 'SELECT getrolesubroles(' + mysql.escape(connid) + ',' + mysql.escape(roleid) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getrolesubroles",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getrolesubroles"]);
			con.end();
		}
	});
});

// Add role to role
app.all('/addroletorole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let owner = '';
	let target = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('owner') || req.body.hasOwnProperty('owner')) {
		owner = req.query.hasOwnProperty('owner') ? req.query["owner"] : req.body["owner"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- owner"));
		return;
	}

	if(req.query.hasOwnProperty('target') || req.body.hasOwnProperty('target')) {
		target = req.query.hasOwnProperty('target') ? req.query["target"] : req.body["target"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- target"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT addroletorole(' + mysql.escape(connid) + ',' + mysql.escape(owner) + ',' + mysql.escape(target) + ',' + mysql.escape(locale) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addroletorole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addroletorole"]);
			con.end();
		}
	});
});

// Add roles to role
app.all('/addrolestorole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let owner = '';
	let targets = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('owner') || req.body.hasOwnProperty('owner')) {
		owner = req.query.hasOwnProperty('owner') ? req.query["owner"] : req.body["owner"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- owner"));
		return;
	}

	if(req.query.hasOwnProperty('targets') || req.body.hasOwnProperty('targets')) {
		targets = req.query.hasOwnProperty('targets') ? req.query["targets"] : req.body["targets"] ;
		if(targets.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- targets"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- targets"));
		return;
	}

	const query = 'SELECT addrolestorole(' + mysql.escape(connid) + ',' + mysql.escape(owner) + ',\'' + JSON.stringify(targets) + '\',' + mysql.escape(locale) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addrolestorole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addrolestorole"]);
			con.end();
		}
	});
});

// Remove role from role
app.all('/removerolefromrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let owner = '';
	let target = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('owner') || req.body.hasOwnProperty('owner')) {
		owner = req.query.hasOwnProperty('owner') ? req.query["owner"] : req.body["owner"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- owner"));
		return;
	}

	if(req.query.hasOwnProperty('target') || req.body.hasOwnProperty('target')) {
		target = req.query.hasOwnProperty('target') ? req.query["target"] : req.body["target"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- target"));
		return;
	}

	const query = 'SELECT removerolefromrole(' + mysql.escape(connid) + ',' + mysql.escape(owner) + ',' + mysql.escape(target) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removerolefromrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removerolefromrole"]);
			con.end();
		}
	});
});

// Add privileges to role
app.all('/removerolesfromrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let owner = '';
	let targets = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('owner') || req.body.hasOwnProperty('owner')) {
		owner = req.query.hasOwnProperty('owner') ? req.query["owner"] : req.body["owner"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- owner"));
		return;
	}

	if(req.query.hasOwnProperty('targets') || req.body.hasOwnProperty('targets')) {
		targets = req.query.hasOwnProperty('targets') ? req.query["targets"] : req.body["targets"] ;
		if(targets.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- targets"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- targets"));
		return;
	}

	const query = 'SELECT removerolesfromrole(' + mysql.escape(connid) + ',' + mysql.escape(owner) + ',\'' + JSON.stringify(targets) + '\')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removerolesfromrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removerolesfromrole"]);
			con.end();
		}
	});
});

// Add roles to role
app.all('/addrolestouser', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let roleids = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('roleids') || req.body.hasOwnProperty('roleids')) {
		roleids = req.query.hasOwnProperty('roleids') ? req.query["roleids"] : req.body["roleids"] ;
		if(roleids.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- roleids"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleids"));
		return;
	}

	const query = 'SELECT addrolestouser(' + mysql.escape(connid) + ',' + mysql.escape(userid) + ',\'' + JSON.stringify(roleids) + '\')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addrolestouser",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addrolestouser"]);
			con.end();
		}
	});
});

// Add roles to role
app.all('/addroletouser', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let roleid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT addroletouser(' + mysql.escape(connid) + ',' + mysql.escape(userid) + ',' + mysql.escape(roleid) + ',' + mysql.escape(locale) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addroletouser",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addroletouser"]);
			con.end();
		}
	});
});

// Remove role from user
app.all('/removeuserrole', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let roleid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('roleid') || req.body.hasOwnProperty('roleid')) {
		roleid = req.query.hasOwnProperty('roleid') ? req.query["roleid"] : req.body["roleid"] ;
		if(!Number.isInteger(parseInt(roleid))) {
			res.send(utils.sendErrorMessage("",453,"Value was not an integer -- roleid"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT removeuserrole(' + mysql.escape(connid) + ',' + mysql.escape(userid) + ',' + mysql.escape(roleid) + ',' + mysql.escape(locale) + ')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removeuserrole",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removeuserrole"]);
			con.end();
		}
	});
});

// Add roles to role
app.all('/removeuserroles', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let roleids = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('roleids') || req.body.hasOwnProperty('roleids')) {
		roleids = req.query.hasOwnProperty('roleids') ? req.query["roleids"] : req.body["roleids"] ;
		if(roleids.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- roleids"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- roleids"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT removeuserroles(' + mysql.escape(connid) + ',' + mysql.escape(userid) + ',\'' + JSON.stringify(roleids) + '\',' + mysql.escape(locale) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removeuserroles",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removeuserroles"]);
			con.end();
		}
	});
});

// Add roles to role
app.get('/resetupass', (req, res) => {
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
		if(!Number.isInteger(parseInt(userid))) {
			res.send(utils.sendErrorMessage("",453,"Value was not an integer -- userid"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	const query = 'CALL resetuserpassword(' + mysql.escape(connid) + ',' + mysql.escape(userid) + ',' + mysql.escape(locale) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("resetuserpassword",err.code,err.message));
		} else {
			res.send(utils.sendSuccessMessage());
			con.end();
		}
	});
});

// Get all classrooms
app.all('/getallclassrooms', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let option = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getallclassrooms('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getallclassrooms",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getallclassrooms"]);
			con.end();
		}
	});
});

// create classroom
app.all('/createclassroom', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let cname = '';
	let abbreviation = '';
	let letter = '';
	let descript = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		cname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('abbrev') || req.body.hasOwnProperty('abbrev')) {
		abbreviation = req.query.hasOwnProperty('abbrev') ? req.query["abbrev"] : req.body["abbrev"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- abbrev"));
		return;
	}

	if(req.query.hasOwnProperty('letter') || req.body.hasOwnProperty('letter')) {
		letter = req.query.hasOwnProperty('letter') ? req.query["letter"] : req.body["letter"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- letter"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	const query = 'SELECT createclassroom('+ mysql.escape(connid)+','+mysql.escape(cname)+','+mysql.escape(abbreviation)+','+mysql.escape(descript)+','+mysql.escape(letter)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createclassroom",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createclassroom"]);
			con.end();
		}
	});
});

// Modify classroom
app.all('/modifyclassroom', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let classid = '';
	let connid = '';
	let cname = '';
	let abbreviation = '';
	let fee = '';
	let descript = '';
	let letter = ''
;
	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		cname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('abbrev') || req.body.hasOwnProperty('abbrev')) {
		abbreviation = req.query.hasOwnProperty('abbrev') ? req.query["abbrev"] : req.body["abbrev"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- abbrev"));
		return;
	}

	if(req.query.hasOwnProperty('letter') || req.body.hasOwnProperty('letter')) {
		letter = req.query.hasOwnProperty('letter') ? req.query["letter"] : req.body["letter"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- letter"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	const query = 'SELECT updateclassroom('+mysql.escape(connid)+','+mysql.escape(classid)+','+mysql.escape(cname)+','+mysql.escape(abbreviation)+','+mysql.escape(descript)+','+mysql.escape(letter)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("updateclassroom",err.code,err.message));
		} else {
			res.send(rows.rows[0]["updateclassroom"]);
			con.end();
		}
	});
});

// Get all subjects
app.all('/getallsubjects', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getallsubjects('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getallsubjects",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getallsubjects"]);
			con.end();
		}
	});
});

// create subject
app.all('/createsubject', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let sname = '';
	let code = '';
	let coef = '';
	let descript = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		sname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('code') || req.body.hasOwnProperty('code')) {
		code = req.query.hasOwnProperty('code') ? req.query["code"] : req.body["code"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- code"));
		return;
	}

	if(req.query.hasOwnProperty('coef') || req.body.hasOwnProperty('coef')) {
		coef = req.query.hasOwnProperty('coef') ? req.query["coef"] : req.body["coef"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- coef"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	const query = 'SELECT createsubject('+ mysql.escape(connid)+','+mysql.escape(sname)+','+mysql.escape(code)+','+mysql.escape(coef)+','+mysql.escape(descript)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createsubject",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createsubject"]);
			con.end();
		}
	});
});

// update subject
app.all('/modifysubject', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let subjectid = '';
	let sname = '';
	let code = '';
	let coef = '';
	let descript = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subjectid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		sname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('code') || req.body.hasOwnProperty('code')) {
		code = req.query.hasOwnProperty('code') ? req.query["code"] : req.body["code"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- code"));
		return;
	}

	if(req.query.hasOwnProperty('coef') || req.body.hasOwnProperty('coef')) {
		coef = req.query.hasOwnProperty('coef') ? req.query["coef"] : req.body["coef"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- coef"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	const query = 'SELECT updatesubject('+ mysql.escape(connid)+','+mysql.escape(subjectid)+','+mysql.escape(sname)+','+mysql.escape(code)+','+mysql.escape(coef)+','+mysql.escape(descript)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("updatesubject",err.code,err.message));
		} else {
			res.send(rows.rows[0]["updatesubject"]);
			con.end();
		}
	});
});

// Get all groups
app.all('/getgroups', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getsubjectgroups('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getsubjectgroups",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getsubjectgroups"]);
			con.end();
		}
	});
});

// create group
app.all('/creategroup', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let gname = '';
	let descript = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		gname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT createsubjectgroup('+ mysql.escape(connid)+','+mysql.escape(gname)+','+mysql.escape(descript) +','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createsubjectgroup",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createsubjectgroup"]);
			con.end();
		}
	});
});

// edit group
app.all('/editgroup', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let groupid = '';
	let gname = '';
	let descript = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('groupid') || req.body.hasOwnProperty('groupid')) {
		groupid= req.query.hasOwnProperty('groupid') ? req.query["groupid"] : req.body["groupid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- groupid"));
		return;
	}

	if(req.query.hasOwnProperty('name') || req.body.hasOwnProperty('name')) {
		gname = req.query.hasOwnProperty('name') ? req.query["name"] : req.body["name"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- name"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT updatesubjectgroup('+ mysql.escape(connid)+','+mysql.escape(groupid)+','+mysql.escape(gname)+','+mysql.escape(descript) +','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("updatesubjectgroup",err.code,err.message));
		} else {
			res.send(rows.rows[0]["updatesubjectgroup"]);
			con.end();
		}
	});
});

// remove group
app.all('/removegroup', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let groupid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('groupid') || req.body.hasOwnProperty('groupid')) {
		groupid= req.query.hasOwnProperty('groupid') ? req.query["groupid"] : req.body["groupid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- groupid"));
		return;
	}

	const query = 'SELECT deletesubjectgroup('+ mysql.escape(connid)+','+mysql.escape(groupid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("deletesubjectgroup",err.code,err.message));
		} else {
			res.send(rows.rows[0]["deletesubjectgroup"]);
			con.end();
		}
	});
});

// fetch group subject
app.all('/getgroupsubjects', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let groupid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('groupid') || req.body.hasOwnProperty('groupid')) {
		groupid= req.query.hasOwnProperty('groupid') ? req.query["groupid"] : req.body["groupid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- groupid"));
		return;
	}

	const query = 'SELECT getgroupsubjects('+ mysql.escape(connid)+','+mysql.escape(groupid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getgroupsubjects",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getgroupsubjects"]);
			con.end();
		}
	});
});

// add group subject
app.all('/addgroupsubject', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let groupid = '';
	let subjectid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('groupid') || req.body.hasOwnProperty('groupid')) {
		groupid= req.query.hasOwnProperty('groupid') ? req.query["groupid"] : req.body["groupid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- groupid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subjectid"));
		return;
	}

	const query = 'SELECT addgroupsubject('+ mysql.escape(connid)+','+mysql.escape(groupid)+ ',' + mysql.escape(subjectid) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addgroupsubject",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addgroupsubject"]);
			con.end();
		}
	});
});

// remove group subject
app.all('/removegroupsubject', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let groupid = '';
	let subjectid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('groupid') || req.body.hasOwnProperty('groupid')) {
		groupid= req.query.hasOwnProperty('groupid') ? req.query["groupid"] : req.body["groupid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- groupid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subjectid"));
		return;
	}

	const query = 'SELECT removegroupsubject('+ mysql.escape(connid)+','+mysql.escape(groupid)+ ',' + mysql.escape(subjectid) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removegroupsubject",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removegroupsubject"]);
			con.end();
		}
	});
});

// Get all academic years
app.all('/getyears', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getacademicyears('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getacademicyears",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getacademicyears"]);
			con.end();
		}
	});
});

// create year
app.all('/createyear', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let descript = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT createacademicyear('+ mysql.escape(connid)+','+mysql.escape(start)+','+mysql.escape(end)+','+mysql.escape(descript) +','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createacademicyear",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createacademicyear"]);
			con.end();
		}
	});
});

// edit year
app.all('/modifyyear', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let descript = '';
	let locale = '';
	let yearid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('yearid') || req.body.hasOwnProperty('yearid')) {
		yearid = req.query.hasOwnProperty('yearid') ? req.query["yearid"] : req.body["yearid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- yearid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('descr') || req.body.hasOwnProperty('descr')) {
		descript = req.query.hasOwnProperty('descr') ? req.query["descr"] : req.body["descr"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- descr"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT modifyacademicyear('+ mysql.escape(connid)+','+mysql.escape(yearid)+','+mysql.escape(start)+','+mysql.escape(end)+','+mysql.escape(descript) +','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("modifyacademicyear",err.code,err.message));
		} else {
			res.send(rows.rows[0]["modifyacademicyear"]);
			con.end();
		}
	});
});

// create year
app.all('/createterm', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let ttype = '';
	let yearid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('ttype') || req.body.hasOwnProperty('ttype')) {
		ttype = req.query.hasOwnProperty('ttype') ? req.query["ttype"] : req.body["ttype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- ttype"));
		return;
	}

	if(req.query.hasOwnProperty('yearid') || req.body.hasOwnProperty('yearid')) {
		yearid = req.query.hasOwnProperty('yearid') ? req.query["yearid"] : req.body["yearid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- yearid"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT createacademicterm('+ mysql.escape(connid)+','+mysql.escape(start)+','+mysql.escape(end)+','+mysql.escape(ttype)+ ',' +  mysql.escape(yearid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createacademicterm",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createacademicterm"]);
			con.end();
		}
	});
});

// create year
app.all('/modifyterm', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let ttype = '';
	let termid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('ttype') || req.body.hasOwnProperty('ttype')) {
		ttype = req.query.hasOwnProperty('ttype') ? req.query["ttype"] : req.body["ttype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- ttype"));
		return;
	}

	if(req.query.hasOwnProperty('termid') || req.body.hasOwnProperty('termid')) {
		termid = req.query.hasOwnProperty('termid') ? req.query["termid"] : req.body["termid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- termid"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT modifyacademicterm('+ mysql.escape(connid)+ ','+mysql.escape(termid)+','+mysql.escape(start)+','+mysql.escape(end)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("modifyacademicterm",err.code,err.message));
		} else {
			res.send(rows.rows[0]["modifyacademicterm"]);
			con.end();
		}
	});
});


// Get all academic terms
app.all('/getterms', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let yearid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('yearid') || req.body.hasOwnProperty('yearid')) {
		yearid = req.query.hasOwnProperty('yearid') ? req.query["yearid"] : req.body["yearid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- yearid"));
		return;
	}
	
	const query = 'SELECT getacademicterms('+ mysql.escape(connid)+','+ mysql.escape(yearid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getacademicterms",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getacademicterms"]);
			con.end();
		}
	});
});

app.all('/gettermtypes', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT gettermtypes('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("gettermtypes",err.code,err.message));
		} else {
			res.send(rows.rows[0]["gettermtypes"]);
			con.end();
		}
	});
});

// Get all examinations
app.all('/getexams', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let termid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('termid') || req.body.hasOwnProperty('termid')) {
		termid = req.query.hasOwnProperty('termid') ? req.query["termid"] : req.body["termid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- termid"));
		return;
	}
	
	const query = 'SELECT getexaminations('+ mysql.escape(connid)+','+ mysql.escape(termid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getexaminations",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getexaminations"]);
			con.end();
		}
	});
});

app.all('/getexamtypes', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getexamtypes('+ mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getexamtypes",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getexamtypes"]);
			con.end();
		}
	});
});

//Creating examination
app.all('/createexam', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let etype = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('etype') || req.body.hasOwnProperty('etype')) {
		etype = req.query.hasOwnProperty('etype') ? req.query["etype"] : req.body["etype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- etype"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT createexam('+ mysql.escape(connid) + ',' + mysql.escape(start) + ',' + mysql.escape(end) + ',' + mysql.escape(etype) + ',' + mysql.escape(locale) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("createexam",err.code,err.message));
		} else {
			res.send(rows.rows[0]["createexam"]);
			con.end();
		}
	});
});

//Creating examination
app.all('/modifyexam', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let start = '';
	let end = '';
	let etype = '';
	let examid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('examid') || req.body.hasOwnProperty('examid')) {
		examid = req.query.hasOwnProperty('termid') ? req.query["termid"] : req.body["examid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- examid"));
		return;
	}

	if(req.query.hasOwnProperty('start') || req.body.hasOwnProperty('start')) {
		start = req.query.hasOwnProperty('start') ? req.query["start"] : req.body["start"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- start"));
		return;
	}

	if(req.query.hasOwnProperty('end') || req.body.hasOwnProperty('end')) {
		end = req.query.hasOwnProperty('end') ? req.query["end"] : req.body["end"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- end"));
		return;
	}

	if(req.query.hasOwnProperty('etype') || req.body.hasOwnProperty('etype')) {
		etype = req.query.hasOwnProperty('etype') ? req.query["etype"] : req.body["etype"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- etype"));
		return;
	}
	
	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT modifyexam('+ mysql.escape(connid) + ',' + mysql.escape(examid) + ',' + mysql.escape(start) + ',' + mysql.escape(end) + ',' + mysql.escape(etype) + ',' + mysql.escape(locale) +')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("modifyexam",err.code,err.message));
		} else {
			res.send(rows.rows[0]["modifyexam"]);
			con.end();
		}
	});
});

// Get all class teachers and subjects
app.all('/getclassroomteachers', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT getclassroomteachers('+ mysql.escape(connid)+','+mysql.escape(classid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getclassroomteachers",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getclassroomteachers"]);
			con.end();
		}
	});
});

// Get all class teachers and subjects
app.all('/getteachersubjects', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}
	
	const query = 'SELECT getteachersubjects('+ mysql.escape(connid)+','+mysql.escape(userid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getteachersubjects",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getteachersubjects"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/addteachersubject', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let userid = '';
	let subjectid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subjectid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT addteacherclassroom('+ mysql.escape(connid)+','+mysql.escape(classid)+','+mysql.escape(userid)+','+mysql.escape(subjectid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addteacherclassroom",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addteacherclassroom"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/addteachersubjects', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classids = '';
	let userid = '';
	let subjectid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classids') || req.body.hasOwnProperty('classids')) {
		classids = req.query.hasOwnProperty('classids') ? req.query["classids"] : req.body["classids"] ;
		if(classids.length == 0) {
			res.send(utils.sendErrorMessage("",453,"Value was not a JSON -- classids"));
			return;
		}
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classids"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subjectid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT addteacherclassrooms('+ mysql.escape(connid)+',\''+JSON.stringify(classids)+'\','+mysql.escape(userid)+','+mysql.escape(subjectid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addteacherclassrooms",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addteacherclassrooms"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/getallstudents', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classids') || req.body.hasOwnProperty('classids')) {
		classid = req.query.hasOwnProperty('classids') ? req.query["classids"] : req.body["classids"] ;
	} else {
		classid = null;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT getallstudents('+ mysql.escape(connid)+','+mysql.escape(classid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getallstudents",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getallstudents"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/createstudent', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let surname = '';
	let othernames = '';
	let dob = '';
	let pob = '';
	let gender = '';
	let classid = '';
	let locale = '';
	let localee = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('surname') || req.body.hasOwnProperty('surname')) {
		surname = req.query.hasOwnProperty('surname') ? req.query["surname"] : req.body["surname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- surname"));
		return;
	}

	if(req.query.hasOwnProperty('othernames') || req.body.hasOwnProperty('othernames')) {
		othernames = req.query.hasOwnProperty('othernames') ? req.query["othernames"] : req.body["othernames"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- othernames"));
		return;
	}

	if(req.query.hasOwnProperty('dob') || req.body.hasOwnProperty('dob')) {
		dob = req.query.hasOwnProperty('dob') ? req.query["dob"] : req.body["dob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- dob"));
		return;
	}

	if(req.query.hasOwnProperty('pob') || req.body.hasOwnProperty('pob')) {
		pob = req.query.hasOwnProperty('pob') ? req.query["pob"] : req.body["pob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- pob"));
		return;
	}

	if(req.query.hasOwnProperty('gender') || req.body.hasOwnProperty('gender')) {
		gender = req.query.hasOwnProperty('gender') ? req.query["gender"] : req.body["gender"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- gender"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('localee') || req.body.hasOwnProperty('localee')) {
		localee = req.query.hasOwnProperty('localee') ? req.query["localee"] : req.body["localee"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- localee"));
		return ;
	}
	
	const query = 'SELECT addstudent('+ mysql.escape(surname)+','+mysql.escape(othernames)+','+
						mysql.escape(dob)+','+mysql.escape(pob)+','+mysql.escape(gender)+','+
						mysql.escape(classid)+','+mysql.escape(locale)+','+mysql.escape(connid)+','+
						mysql.escape(localee)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addstudent",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addstudent"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/modifystudent', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let surname = '';
	let othernames = '';
	let dob = '';
	let pob = '';
	let gender = '';
	let classid = '';
	let locale = '';
	let userid = '';
	let localee = '';

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('surname') || req.body.hasOwnProperty('surname')) {
		surname = req.query.hasOwnProperty('surname') ? req.query["surname"] : req.body["surname"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- surname"));
		return;
	}

	if(req.query.hasOwnProperty('othernames') || req.body.hasOwnProperty('othernames')) {
		othernames = req.query.hasOwnProperty('othernames') ? req.query["othernames"] : req.body["othernames"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- othernames"));
		return;
	}

	if(req.query.hasOwnProperty('dob') || req.body.hasOwnProperty('dob')) {
		dob = req.query.hasOwnProperty('dob') ? req.query["dob"] : req.body["dob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- dob"));
		return;
	}

	if(req.query.hasOwnProperty('pob') || req.body.hasOwnProperty('pob')) {
		pob = req.query.hasOwnProperty('pob') ? req.query["pob"] : req.body["pob"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- pob"));
		return;
	}

	if(req.query.hasOwnProperty('gender') || req.body.hasOwnProperty('gender')) {
		gender = req.query.hasOwnProperty('gender') ? req.query["gender"] : req.body["gender"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- gender"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('localee') || req.body.hasOwnProperty('localee')) {
		localee = req.query.hasOwnProperty('localee') ? req.query["localee"] : req.body["localee"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- localee"));
		return ;
	}
	
	const query = 'SELECT editstudent('+mysql.escape(userid)+','+ mysql.escape(surname)+','+mysql.escape(othernames)+','+
						mysql.escape(dob)+','+mysql.escape(pob)+','+mysql.escape(gender)+','+
						mysql.escape(classid)+','+mysql.escape(locale)+','+mysql.escape(connid)+','+
						mysql.escape(localee)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("editstudent",err.code,err.message));
		} else {
			res.send(rows.rows[0]["editstudent"]);
			con.end();
		}
	});
});

// Add classroom to a teacher
app.all('/getstudentparents', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let locale = '';
	let userid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}
	
	const query = 'SELECT fetchstudentparents('+mysql.escape(userid)+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("fetchstudentparents",err.code,err.message));
		} else {
			res.send(rows.rows[0]["fetchstudentparents"]);
			con.end();
		}
	});
});

// Removes a student parent
app.all('/removestudentparent', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let locale = '';
	let studentid = '';
	let parentid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('studentid') || req.body.hasOwnProperty('studentid')) {
		studentid = req.query.hasOwnProperty('studentid') ? req.query["studentid"] : req.body["studentid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- studentid"));
		return;
	}

	if(req.query.hasOwnProperty('parentid') || req.body.hasOwnProperty('parentid')) {
		parentid = req.query.hasOwnProperty('parentid') ? req.query["parentid"] : req.body["parentid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- parentid"));
		return;
	}
	
	const query = 'SELECT removestudentparent('+mysql.escape(studentid)+','+mysql.escape(parentid)+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removestudentparent",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removestudentparent"]);
			con.end();
		}
	});
});

// Removes a student parent
app.all('/addstudentparent', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let locale = '';
	let studentid = '';
	let parentid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('studentid') || req.body.hasOwnProperty('studentid')) {
		studentid = req.query.hasOwnProperty('studentid') ? req.query["studentid"] : req.body["studentid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- studentid"));
		return;
	}

	if(req.query.hasOwnProperty('parentid') || req.body.hasOwnProperty('parentid')) {
		parentid = req.query.hasOwnProperty('parentid') ? req.query["parentid"] : req.body["parentid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- parentid"));
		return;
	}
	
	const query = 'SELECT addstudentparent('+mysql.escape(studentid)+','+mysql.escape(parentid)+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addstudentparent",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addstudentparent"]);
			con.end();
		}
	});
});

// Get student fees
app.all('/getstudentfees', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let userid = '';
	let print = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('print') || req.body.hasOwnProperty('print')) {
		print = req.query.hasOwnProperty('print') ? req.query["print"] : req.body["print"] ;

		const query = 'SELECT getstudentfees('+mysql.escape(connid)+','+mysql.escape(userid)+')';

		con.query(query, async (err, rows) => {
			if (err) {
				con.end();
				res.send(utils.sendErrorMessage("getstudentfees",err.code,err.message));
			} else {
				if(print || print === 'true') {
					
					let header;
					Heads.map((e)=> {
						if (e.org_id === 1) {
							header = e; 
						}
					});
					
					const result = JSON.parse(rows.rows[0]["getstudentfees"]); 
					const start = new Date(result.result.calendar[0].startdate).getFullYear();
					const end = new Date(result.result.calendar[0].enddate).getFullYear();

					const year = start + " / " + end ;
					const sname = `${result.result.details[0].surname} ${result.result.details[0].othernames}`;
					let currentyear = year.replace("/","-");
					header['items'] = result.result.value;	
					header['details'] = result.result.details;  
					header['year'] = year;
					
					axios.post('http://localhost:6000/studentreceipts', { data: JSON.stringify(header) }).then((response) => {
						if (!response.data.error) {
							const bitmap = fs.readFileSync(`./uploads/studentreceipts/${currentyear}/${sname}.pdf`, 'base64');
							res.send(`{"error":false,"data":"${bitmap}"}`);
						}	
					}).catch((err) => { 
						res.send(utils.sendErrorMessage("",453,err.code + ' on ' + err.port));
					});
				} else {
					res.send(rows.rows[0]["getstudentfees"]);
				}
				con.end();
			}
		});

	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- print"));
		return ;
	}
	
});

// Get fee types
app.all('/getfeetypes', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getfeetypes('+mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getfeetypes",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getfeetypes"]);
			con.end();
		}
	});
});

// Get payment methods
app.all('/getpaymethods', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}
	
	const query = 'SELECT getpaymethods('+mysql.escape(connid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getpaymethods",err.code,err.message));
		} else {
			res.send(rows.rows[0]["getpaymethods"]);
			con.end();
		}
	});
});

app.all('/addstudentfee', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let type = '';
	let method = '';
	let amount = '';
	let reference = '';
	let userid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('type') || req.body.hasOwnProperty('type')) {
		type = req.query.hasOwnProperty('type') ? req.query["type"] : req.body["type"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- type"));
		return;
	}

	if(req.query.hasOwnProperty('method') || req.body.hasOwnProperty('method')) {
		method = req.query.hasOwnProperty('method') ? req.query["method"] : req.body["method"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- method"));
		return;
	}

	if(req.query.hasOwnProperty('amount') || req.body.hasOwnProperty('amount')) {
		amount = req.query.hasOwnProperty('amount') ? req.query["amount"] : req.body["amount"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- amount"));
		return;
	}

	if(req.query.hasOwnProperty('reference') || req.body.hasOwnProperty('reference')) {
		reference = req.query.hasOwnProperty('reference') ? req.query["reference"] : req.body["reference"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- reference"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT addstudentfee('+mysql.escape(connid)+','+mysql.escape(userid)+','+mysql.escape(type)+','+mysql.escape(method)+','+mysql.escape(amount)+','+mysql.escape(reference)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("addstudentfee",err.code,err.message));
		} else {
			res.send(rows.rows[0]["addstudentfee"]);
			con.end();
		}
	});
});

app.all('/editstudentfee', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let feeid = '';
	let type = '';
	let method = '';
	let amount = '';
	let reference = '';
	let userid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('type') || req.body.hasOwnProperty('type')) {
		type = req.query.hasOwnProperty('type') ? req.query["type"] : req.body["type"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- type"));
		return;
	}

	if(req.query.hasOwnProperty('method') || req.body.hasOwnProperty('method')) {
		method = req.query.hasOwnProperty('method') ? req.query["method"] : req.body["method"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- method"));
		return;
	}

	if(req.query.hasOwnProperty('amount') || req.body.hasOwnProperty('amount')) {
		amount = req.query.hasOwnProperty('amount') ? req.query["amount"] : req.body["amount"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- amount"));
		return;
	}

	if(req.query.hasOwnProperty('reference') || req.body.hasOwnProperty('reference')) {
		reference = req.query.hasOwnProperty('reference') ? req.query["reference"] : req.body["reference"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- reference"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('feeid') || req.body.hasOwnProperty('feeid')) {
		feeid = req.query.hasOwnProperty('feeid') ? req.query["userid"] : req.body["feeid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- feeid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}
	
	const query = 'SELECT updatestudentfee('+mysql.escape(connid)+','+mysql.escape(feeid)+','+mysql.escape(userid)+','+mysql.escape(type)+','+mysql.escape(method)+','+mysql.escape(amount)+','+mysql.escape(reference)+','+mysql.escape(locale)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("updatestudentfee",err.code,err.message));
		} else {
			res.send(rows.rows[0]["updatestudentfee"]);
			con.end();
		}
	});
});

app.all('/deletestudentfee', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let feeid = '';
	let userid = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('userid') || req.body.hasOwnProperty('userid')) {
		userid = req.query.hasOwnProperty('userid') ? req.query["userid"] : req.body["userid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.query.hasOwnProperty('feeid') || req.body.hasOwnProperty('feeid')) {
		feeid = req.query.hasOwnProperty('feeid') ? req.query["userid"] : req.body["feeid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- feeid"));
		return;
	}
	
	const query = 'SELECT removestudentfee('+mysql.escape(connid)+','+mysql.escape(feeid)+','+mysql.escape(userid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("removestudentfee",err.code,err.message));
		} else {
			res.send(rows.rows[0]["removestudentfee"]);
			con.end();
		}
	});
});

const upload = multer({});
app.post('/uploadstudentphoto', upload.single("picture"), async (req, res, next) => { 
	const con = new Client(conndetails);
	con.connect();

	let userid = '';
	let matricule = '';
	let connid = '';
	let locale = '';

	if(req.body['userid']) {
		userid = req.body['userid'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.body['connid']) {
		connid = req.body['connid'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.body['matricule']) {
		matricule = req.body['matricule'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- matricule"));
		return;
	}

	if(req.body['locale']) {
		locale = req.body['locale'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	if(req.file !== undefined) {
		const filename = matricule.trim()+'.'+req.file.mimetype.split('/')[1];

		const query = 'SELECT updatestudentpicture('+mysql.escape(userid)+','+mysql.escape(filename)+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

		con.query(query, async (err, rows) => {
			if (err) {
				con.end();
				res.send(utils.sendErrorMessage("updatestudentpicture",err.code,err.message));
			} else {
				const tes = await fs.promises.open(`uploads/students/${filename}`, 'w');
				await tes.write(req.file.buffer);
				res.send(rows.rows[0]["updatestudentpicture"]);
				con.end();
			}
		});
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- picture"));
		return;
	}
});

const getpic = multer({});
app.post('/getstudentphoto',getpic.single('picture'), async (req, res, next) => { 
	const con = new Client(conndetails);
	con.connect();

	let userid = ''; 
	let matricule = '';
	let connid = '';
	let locale = '';

	if(req.body['userid']) {
		userid = req.body['userid'];  
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- userid"));
		return;
	}

	if(req.body['connid']) {
		connid = req.body['connid'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.body['locale']) {
		locale = req.body['locale'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	const query = 'SELECT getstudentpicture('+mysql.escape(userid)+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

	con.query(query, async (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("getstudentpicture",err.code,err.message));
		} else {
			const path = JSON.parse(rows.rows[0]["getstudentpicture"]).result.value[0].picture;
			if(path !== null) {
				var extension = path.split('.')[1];
				
				fs.readFile(`uploads/students/${path}`, function(err, data) {
					if (err) {
						res.send(utils.sendErrorMessage("getstudentpicture",err.code,err.message));
					} else {
						const image = "data:image/"+extension+";base64,"+data.toString('base64');
						const value = '{"error":false,"result":{"status":200,"value":[{"picture":"'+image+'"}]}}';
						res.send(value);
					}
				})
			} else {
				const value = '{"error":false,"result":{"status":200,"value":[{"picture":""}]}}';
				res.send(value);
			}
			
			con.end();
		}
	});
});

const studentUpload = multer({}); 
app.post('/uploadstudents', studentUpload.single("batch"), async (req, res, next) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let locale = '';

	if(req.body['connid']) {
		connid = req.body['connid'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.body['locale']) {
		locale = req.body['locale'] === 'null'? 'en_US' : req.body['locale'];
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return;
	}

	if(req.file !== undefined) {
		const filename = req.file.fieldname+'.'+req.file.mimetype.split('/')[1];

		const tes = await fs.promises.open(`uploads/batch/${filename}`, 'w');
		await tes.write(req.file.buffer);

		csv()
			.fromFile(`uploads/batch/${filename}`)
			.then(function(jsonArrayObj){ //when parse finished, result will be emitted here.
				const query = 'SELECT uploadbatchstudents('+mysql.escape(JSON.stringify(jsonArrayObj))+','+mysql.escape(connid)+','+mysql.escape(locale)+')';

				con.query(query, async (err, rows) => {
					if (err) {
						con.end();
						res.send(utils.sendErrorMessage("uploadbatchstudents",err.code,err.message));
					} else {
						res.send(rows.rows[0]["uploadbatchstudents"]);
						con.end();
					}
				});
			})
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- batch"));
		return;
	}
});

// Get all class teachers and subjects
app.all('/getclassroomstudents', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let locale = '';
	let print = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('print') || req.body.hasOwnProperty('print')) {
		print = req.query.hasOwnProperty('print') ? req.query["print"] : req.body["print"] ;

		const query = 'SELECT getclassroomstudents('+ mysql.escape(connid)+','+mysql.escape(classid)+','+mysql.escape(locale)+')';

		con.query(query, async (err, rows) => {
			if (err) {
				con.end();
				res.send(utils.sendErrorMessage("getclassroomstudents",err.code,err.message));
			} else {
				if(print || print === 'true') {
					
					let header;
					Heads.map((e)=> {
						if (e.org_id === 1) {
							header = e; 
						}
					});
					
					const result = JSON.parse(rows.rows[0]["getclassroomstudents"]); 
					const start = new Date(result.result.calendar[0].startdate).getFullYear();
					const end = new Date(result.result.calendar[0].enddate).getFullYear();

					const year = start + " - " + end ;
					const cname = result.result.details[0].cname;
					header['items'] = result.result.value;	
					header['details'] = cname;  
					header['year'] = year;
					
					axios.post('http://localhost:6000/classlist', { data: JSON.stringify(header) }).then((response) => {
						if (!response.data.error) {
							let clname = cname.replace(/ /g, "_");
							const bitmap = fs.readFileSync(`./uploads/classlists/${year}/${clname}.pdf`, 'base64');
							res.send(`{"error":false,"data":"${bitmap}"}`);
						} else {
							res.send(response.data);
						}
					}).catch((err) => { 
						res.send(utils.sendErrorMessage("",453,err.code + ' on ' + err.port));
					});
				} else {
					res.send(rows.rows[0]["getclassroomstudents"]);
				}
				con.end();
			}
		});
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- print"));
		return ;
	}
});

// Get all class teachers and subjects
app.all('/beginsequenceentry', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let subjectid = '';
	let userid = '';
	let locale = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subject"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	const query = 'SELECT beginsequenceentry('+mysql.escape(connid)+','+mysql.escape(locale)+','+mysql.escape(classid)+','+mysql.escape(subjectid)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("beginsequenceentry",err.code,err.message));
		} else {
			res.send(rows.rows[0]["beginsequenceentry"]);
			con.end();
		}
	});
});

// Submit sequence marks
app.all('/submitmarks', (req, res) => { 
	const con = new Client(conndetails);
	con.connect();

	let connid = '';
	let classid = '';
	let subjectid = '';
	let userid = '';
	let locale = '';
	let data = '';

	if(req.query.hasOwnProperty('connid') || req.body.hasOwnProperty('connid')) {
		connid = req.query.hasOwnProperty('connid') ? req.query["connid"] : req.body["connid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- connid"));
		return;
	}

	if(req.query.hasOwnProperty('classid') || req.body.hasOwnProperty('classid')) {
		classid = req.query.hasOwnProperty('classid') ? req.query["classid"] : req.body["classid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- classid"));
		return;
	}

	if(req.query.hasOwnProperty('subjectid') || req.body.hasOwnProperty('subjectid')) {
		subjectid = req.query.hasOwnProperty('subjectid') ? req.query["subjectid"] : req.body["subjectid"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- subject"));
		return;
	}

	if(req.query.hasOwnProperty('locale') || req.body.hasOwnProperty('locale')) {
		locale = req.query.hasOwnProperty('locale') ? req.query["locale"] : req.body["locale"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- locale"));
		return ;
	}

	if(req.query.hasOwnProperty('data') || req.body.hasOwnProperty('data')) {
		data = req.query.hasOwnProperty('data') ? req.query["data"] : req.body["data"] ;
	} else {
		res.send(utils.sendErrorMessage("",453,"Missing required parameter -- data"));
		return ;
	}
	
	const query = 'SELECT submitsequencemarks('+mysql.escape(connid)+','+mysql.escape(locale)+','+mysql.escape(classid)+','+mysql.escape(subjectid)+','+mysql.escape(data)+')';

	con.query(query, (err, rows) => {
		if (err) {
			con.end();
			res.send(utils.sendErrorMessage("submitsequencemarks",err.code,err.message));
		} else {
			res.send(rows.rows[0]["submitsequencemarks"]);
			con.end();
		}
	});

});

app.listen(port, () => {
	console.log(`SMS app listening on port ${port}`)
})
  
export default app;