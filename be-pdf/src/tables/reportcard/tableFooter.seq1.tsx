import React, { Fragment } from 'react';
import {Text, View, StyleSheet, Font } from '@react-pdf/renderer';
import { RegisteredFonts } from '../../fonts/font';

const borderColor = '#000000';

const styles = StyleSheet.create({
    container: {
        display: 'flex',
        flexDirection: 'row',
        borderBottomColor: '#000000',
        borderTopColor: '#000000',
        borderColor: '#000000',
        borderBottomWidth: 1,
        backgroundColor: '#FFF',
        textAlign: 'left',
        fontSize: 7
    },

    appreciation: {
        width: '20%'
    },

    summary: {
        width: '80%',
        borderRight: '#000000',
        borderRightWidth: 1
    },

    summaryTitle: {
        height: 11,
        textTransform: 'uppercase',
        borderBottomColor: '#000000',
        borderBottomWidth: 1,
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#adabab',
        fontFamily: RegisteredFonts.BoldSans,
        fontWeight: 'bold'
    },

    summaryData: {
      width: '100%'
    },

    summaryDataRow1: {
        display: 'flex',
        flexDirection: 'row',
        borderBottomWidth: 1,
        height: 20,
        width: '100%',
        fontFamily: RegisteredFonts.BoldSans,
		fontWeight: 'bold',
		lineHeight: 2
    },

	summaryDataRow1_special: {
        display: 'flex',
        flexDirection: 'row',
        borderBottomWidth: 1,
        height: 11,
        width: '100%',
        fontFamily: RegisteredFonts.BoldSans,
		fontWeight: 'bold'
    },

    summaryDataRow11: {
      borderRightWidth: 1,
      borderRightColor: '#000000',
      width: '30%',
      display: 'flex',
      flexDirection: 'column',
	  justifyContent: 'center',
      paddingLeft: 5,
	  height: '100%'
    },

    summaryDataRow12: {
      width: '70%',
      display: 'flex',
      flexDirection: 'column',
	  justifyContent: 'center',
      paddingLeft: 5,
	  height: '100%',
	  color: '#191970'
    },

	conductRow: {
		width: '100%',
		display: 'flex',
		flexDirection: 'row',
		justifyContent: 'center',
		borderbottomWidth: 1,
      	borderBottomColor: '#000000',
	},

	conductCol1: {
		width: '50%',
		borderRightWidth: 1,
      	borderRightColor: '#FFFFFF',

	},

	conductCol2: {
		width: '50%'
	},

	conductRow1: {
		display: 'flex',
		flexDirection: 'row',
		height: 11,
		alignItems: 'center',
		borderRightWidth: 1,
      	borderRightColor: '#000000',
		paddingLeft: 5,
		width: '100%'
	},

	conductRow2: {
		display: 'flex',
		flexDirection: 'row',
		height: 11,
		alignItems: 'center',
		paddingLeft: 5,
		width: '100%'
	},

	checkbox: {
		width: 6,
		height: 6,
		border: '1pt solid black',
		marginRight: 5,
		display: 'flex',
		justifyContent: 'center',
		alignItems: 'center',
		marginLeft: 5
	},

	councilRow: {
		width: '100%',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		borderbottomWidth: 1,
      	borderBottomColor: '#000000',
	},

	appreciationRow1: {
		textTransform: 'uppercase',
		fontFamily: RegisteredFonts.BoldSans,
		fontWeight: 'bold',
		width: '100%',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignContent: 'center',
		alignItems: 'center',
		paddingBottom: 100
	},

	appreciationRow2: {
		fontFamily: RegisteredFonts.ItalicsSans,
		fontStyle: 'italic',
		fontWeight: 'bold',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignContent: 'center',
		alignItems: 'center',
		paddingBottom: 10
	},

	appreciationRow3: {
		fontFamily: RegisteredFonts.BoldSans,
		fontWeight: 'bold',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignContent: 'center',
		alignItems: 'center',
		paddingBottom: 30
	},

	appreciationRow4: {
		textTransform: 'uppercase',
		fontFamily: RegisteredFonts.BoldSans,
		fontWeight: 'bold',
		width: '100%',
		display: 'flex',
		flexDirection: 'column',
		justifyContent: 'center',
		alignContent: 'center',
		alignItems: 'center'
	},
    
  });

  const Remarks = (mark: number) => {
    let remark: any;
  
    if (mark < 10) {
      remark = "Not Acquired / Non Acquis";
    } else if (mark < 13) {
      remark = "Acquisition in prog/En cours d'Acq";
    } else if (mark < 15) {
      remark = "Acquired / Acquis";
    } else if (mark <= 20) {
      remark = "Expert / Experte";
    } else {
      remark = "Error";
    }
  
    return remark;
  };

  const Rangs = (rank: number) => {
	let suffix: any;
	if (rank === 1) {
	  suffix = "st";
	} else if (rank === 2) {
	  suffix = "nd";
	} else if (rank === 3) {
	  suffix = "rd";
	} else if (rank >= 4 && rank <= 20) {
	  suffix = "th";
	} else {
	  const lastDigit = rank % 10;
	  switch (lastDigit) {
		case 1:
		  suffix = "st";
		  break;
		case 2:
		  suffix = "nd";
		  break;
		case 3:
		  suffix = "rd";
		  break;
		default:
		  suffix = "th";
	  }
	}

	return rank+suffix;
  };

  const Seq1TableFooter = ({details, subjects, alldata}) => {
    const sequence1 = details[0][0];

	let totalmcoef = 0;
	let totalcoef = 0;
    
    //Loop through all the groups for this student
    sequence1.map((item: any, index: any) => {
		const groupmarks = item[0];

		groupmarks.map((marks: any, count: any) => {
			let currentsubject = subjects.find((obj: any) => obj.subjectid === marks.suid) ;
			totalcoef = totalcoef + currentsubject.coefficient;
			totalmcoef = totalmcoef + (marks.mark * currentsubject.coefficient) ;
		});
    });

	let allstudenttotals = [];
	alldata.map((currentstudent: any) => {
		const currentsequence1 = currentstudent[0][0][0];
		let studenttotal = 0;

		currentsequence1.map((currentgroup: any) => {
			const currentgroupmarks = currentgroup[0];

			currentgroupmarks.forEach((obj: any) => {
				let currentsubject = subjects.find((sub: any) => sub.subjectid === obj.suid) ;
				studenttotal = studenttotal + (obj.mark * currentsubject.coefficient);
			});
		});
		allstudenttotals.push(studenttotal);
	});

	allstudenttotals = allstudenttotals.sort((a,b) => b - a);

	let allstudentaverages = [];
	allstudenttotals.forEach((total: any) => {
		let avg = total / totalcoef;
		allstudentaverages.push(parseFloat(avg.toFixed(2)));
	})

	allstudentaverages.sort((a,b) => b - a);
	let generalaverage = 0;
	allstudentaverages.forEach((obj: any) => {
		generalaverage += obj;
	}) ;
	generalaverage = generalaverage / allstudentaverages.length ;
	let highest = Math.max(...allstudentaverages);
	let lowest = Math.min(...allstudentaverages);

    const footer = <View style={styles.container}>
						<View style={styles.summary}>
							<View style={styles.summaryTitle}><Text>Recapitulatif du 1ère séquence / summary of 1st sequence</Text></View>
							<View style={styles.summaryData}>
								<View style={styles.summaryDataRow1}>
									<View style={styles.summaryDataRow11}><Text>Total</Text></View>
									<View style={styles.summaryDataRow12}>
										<Text>Seq1</Text>
										<Text>{(totalmcoef).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
									</View>
								</View>
								<View style={styles.summaryDataRow1}>
									<View style={styles.summaryDataRow11}>
										<Text>Average</Text>
										<Text>Moyenne</Text>
									</View>
									<View style={styles.summaryDataRow12}>
										<Text>{(totalmcoef/totalcoef).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2, maximumFractionDigits: 2})}</Text>
									</View>
								</View>
								<View style={styles.summaryDataRow1_special}>
									<View style={styles.summaryDataRow11}>
										<Text>Rang</Text>
									</View>
									<View style={styles.summaryDataRow12}>
										<Text>{Rangs(allstudenttotals.indexOf(totalmcoef) + 1)}</Text>
									</View>
								</View>
							</View>
							<View style={styles.summaryTitle}><Text>Profil de la classe / Class Profile</Text></View>
							<View style={styles.summaryDataRow1}>
								<View style={styles.summaryDataRow11}>
									<Text>Class average</Text>
									<Text>Moyenne general</Text>
								</View>
								<View style={styles.summaryDataRow12}>
									<Text>{(generalaverage).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2, maximumFractionDigits: 2})}</Text>
								</View>
							</View>
							<View style={styles.summaryDataRow1}>
								<View style={styles.summaryDataRow11}>
									<Text>Highest average</Text>
									<Text>Moyenne du premier(e)</Text>
								</View>
								<View style={styles.summaryDataRow12}>
									<Text>{(highest).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2, maximumFractionDigits: 2})}</Text>
								</View>
							</View>
							<View style={styles.summaryDataRow1}>
								<View style={styles.summaryDataRow11}>
									<Text>Lowest average</Text>
									<Text>Moyenne du dernier(e)</Text>
								</View>
								<View style={styles.summaryDataRow12}>
									<Text>{(lowest).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2, maximumFractionDigits: 2})}</Text>
								</View>
							</View>
							<View style={styles.conductRow}>
								<View style={styles.conductCol1}>
									<View style={styles.summaryTitle}><Text>Appreciations of first sequence's academic work</Text></View>
									<View style={styles.conductRow1}>
										<Text>Tableau d'honneur / Honor's roll</Text>
										<Text style={styles.checkbox}></Text>
									</View>
									<View style={styles.conductRow1}>
										<Text>Distinctions / Encouragements</Text>
										<Text style={styles.checkbox}></Text>
									</View>
									<View style={styles.conductRow1}>
										<Text>Congratulations / Felicitations</Text>
										<Text style={styles.checkbox}></Text>
									</View>
								</View>
								<View style={styles.conductCol2}>
									<View style={styles.summaryTitle}><Text>Student's conduct / Conduite de l'élève</Text></View>
									<View style={styles.conductRow2}><Text>Absences ___H Exclusion temp/Temp.suspension:___Jour(s)/Day(s)</Text></View>
									<View style={styles.conductRow2}>
										<Text>Advertisement / Warning</Text>
										<Text style={styles.checkbox}></Text>
									</View>
									<View style={styles.conductRow2}>
										<Text>Blâme / Serious warning</Text>
										<Text style={styles.checkbox}></Text>
									</View>
								</View>
							</View>
							<View style={styles.summaryTitle}><Text>Classs council's remarks / Remarques du conseil de classe</Text></View>
							<View style={styles.councilRow}>
								<View style={styles.conductRow2}><Text>Un effort s'impose en / Must improve in:_________________________________________________________________________________</Text></View>
								<View style={styles.conductRow2}><Text>_________________________________________________________________________________________________________________</Text></View>
							</View>
						</View>
						<View style={styles.appreciation}>
							<View style={styles.appreciationRow1}>
								<Text>Principal's Remarks</Text>
								<Text>Appreciation du proviseur</Text>
							</View>
							<View style={styles.appreciationRow2}>
								<Text>{Remarks(totalmcoef/totalcoef)}</Text>
							</View>
							<View style={styles.appreciationRow3}>
								<Text>Douala le, _____________________</Text>
							</View>
							<View style={styles.appreciationRow4}>
								<Text>Le proviseur</Text>
								<Text>The principal</Text>
							</View>
						</View>
                  </View>

    return (<Fragment>{footer}</Fragment> )
  };
  
  export default Seq1TableFooter;