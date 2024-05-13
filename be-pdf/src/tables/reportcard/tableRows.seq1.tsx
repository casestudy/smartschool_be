import React, { Fragment } from 'react';
import {Text, View, StyleSheet, Font } from '@react-pdf/renderer';

const borderColor = '#000000';

Font.register({
    family: 'Open Sans',
    fonts: [
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
    ]
});

const styles = StyleSheet.create({
    container: {
        display: 'flex',
        flexDirection: 'row',
        borderBottomColor: '#000000',
        borderTopColor: '#000000',
        borderBottomWidth: 1,
        backgroundColor: '#FFF',
        alignItems: 'center',
        height: 20,
        textAlign: 'left',
        fontSize: 7,
        lineHeight: 2
    },

    grouptitles: {
        display: 'flex',
        flexDirection: 'row',
        width: '100%',
        textTransform: 'uppercase',
        justifyContent: 'center',
        alignItems: 'center',
        alignContent: 'center'
    },

    subjects: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '20%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        fontWeight: 1000,
        height: '100%'
    },

    coef: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '5%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        height: '100%'
        
    },

    seq1: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '10%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        height: '100%'
    },

    tmp: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '65%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        height: '100%'
    },

    remarks : {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '20%',
        paddingLeft: 5,
        fontWeight: 1000,
        height: '100%'
    }
    
  });

  const Seq1TableRow = ({details, subjects, alldata}) => {
    const sequence1 = details[0][0];

    const group = sequence1.map((item: any, index: any) => {
        const groupmarks = item[0];
        const groupbio = item[1];

        const row = <View style={styles.container} key={`group: ${index}`}>
                        <View style={styles.grouptitles}><Text>{groupbio[0].gname}</Text></View>
                    </View>

        const grouptable = groupmarks.map((marks: any, count: any) => {
            let currentsubject = subjects.find((obj: any) => obj.subjectid === marks.suid) ;

            let allcurrentsubject = [];

            alldata.map((currentstudent: any) => {
                const currentsequence1 = currentstudent[0][0][0];

                currentsequence1.map((currentgroup: any) => {
                    const currentgroupmarks = currentgroup[0];

                    currentgroupmarks.forEach((obj: any) => {
                        if(obj.suid === marks.suid) {
                            allcurrentsubject.push(obj);
                        }
                    });
                    
                });
            });

            allcurrentsubject = allcurrentsubject.sort((a, b) => b.mark - a.mark);

            const highest = allcurrentsubject.reduce((max:any, current:any) => {
                if(max.mark < current.mark) {
                    return current;
                }
                return max;
            });

            const lowest= allcurrentsubject.reduce((max:any, current:any) => {
                if(max.mark < current.mark) {
                    return max;
                }
                return current;
            });

            let generalaverage = 0;
            allcurrentsubject.forEach((obj: any) => {
                generalaverage += obj.mark;
            }) ;

            generalaverage = generalaverage / allcurrentsubject.length ;

            const rank = allcurrentsubject.findIndex((obj: any) => obj.mark === marks.mark);

            const subject = <View style={styles.container} key={count}>
                                <View style={styles.subjects}>
                                    <Text>{currentsubject.sname} ({currentsubject.code})</Text>
                                    <Text>{currentsubject.surname} {currentsubject.othernames}</Text>
                                </View>
                                <View style={styles.coef}>
                                    <Text>{currentsubject.coefficient}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{(marks.mark).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{(marks.mark * currentsubject.coefficient).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{rank+1}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{(highest.mark).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{(lowest.mark).toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
                                </View>
                                <View style={styles.seq1}>
                                    <Text>{generalaverage.toLocaleString('en-US',{minimumIntegerDigits: 2,minimumFractionDigits: 2})}</Text>
                                </View>
                                <View style={styles.remarks}>
                                    <Text>{marks.mark * currentsubject.coefficient}</Text>
                                </View>
                            </View> ;
            return subject;
        }) ;

        const groupsummary = <View style={styles.container} key={`summary: ${index}`}>
                                <View style={styles.grouptitles}><Text>SUMMARY / RÉSUMÉ</Text></View>
                            </View>;

        return <View key={`grouptable: ${index}`}>{row}{grouptable}{groupsummary}</View>;

    });

    return (<Fragment>{group}</Fragment> )
  };
  
  export default Seq1TableRow;