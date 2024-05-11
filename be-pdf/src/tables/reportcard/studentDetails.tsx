import React, { Fragment } from 'react';
import {Text, View, StyleSheet, Font, Image } from '@react-pdf/renderer';

const borderColor = '#000000';

Font.register({
    family: 'Open Sans',
    fonts: [
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
    ]
});

const styles = StyleSheet.create({
    general: {
        fontSize: 7
    },
    container: {
        fontFamily: "Open Sans",
        flexDirection: "row",
        fontSize: 7,
        lineHeight: 2,
        fontWeight: 2000,
        display: "flex",
        flexGrow: 1
    },
    col1: {
        display: 'flex',
        flexBasis: '25%'
    },
    col11: {
        display: 'flex',
        flexDirection: 'row'
    },
    col2: {
        display: 'flex',
        flexBasis: '25%'
    },
    col3: {
        display: 'flex',
        flexBasis: '30%'
    },
    col4: {
        display: 'flex',
        flexBasis: '20%'
    },

    image: {
        height: 50,
        width: 50,
        borderRadius: '10%'
    },
  });

  const StudentDetailsTable = ({student, classroom, total}) => {
    const studentBio = student[0];
    const classsroomBio = classroom[0];

    const table = 
                <View style={styles.container}>
                    <View style={styles.col1}>
                        <View style={styles.col11}>
                            <View style={{color: "#800000"}}><Text>Classe / Class: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text>{classsroomBio.cname} ({classsroomBio.abbreviation})</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View style={{color: "#191970"}}><Text>Noms / Name: </Text></View>
                            <View style={{textTransform: 'uppercase'}}><Text>{studentBio.sname}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View><Text>Né(e) le / Born on: </Text></View>
                            <View style={{color: "#191970"}}><Text>{studentBio.dob}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View><Text>Tuteur / Guardian: </Text></View>
                            <View style={{color: "#191970"}}><Text></Text></View>
                        </View>
                    </View>
                    <View style={styles.col2}>
                        <View style={styles.col11}>
                            <View><Text>Effectif / Number on roll: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text>{total}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View style={{color: "#800000"}}><Text>Prénom / Surname: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text>{studentBio.oname}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View style={{color: "#191970"}}><Text>À / In </Text></View>
                            <View style={{textTransform: 'uppercase'}}><Text>{studentBio.pob}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View><Text>Telephone: </Text></View>
                            <View style={{color: "#191970"}}><Text></Text></View>
                        </View>
                    </View>
                    <View style={styles.col3}>
                        <View style={styles.col11}>
                            <View><Text>Prof. Principal / Class Master: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text>{classsroomBio.surname} {classsroomBio.othernames}</Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View><Text>Redoublant(e) / Repeater: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text></Text></View>
                        </View>
                        <View style={styles.col11}>
                            <View><Text>Matricule: </Text></View>
                            <View style={{color: "#191970", textTransform: 'uppercase'}}><Text>{studentBio.matricule}</Text></View>
                        </View>
                    </View>
                    <View style={styles.col4}>
                        {studentBio.picture != null? <Image style={styles.image} source={`../be/uploads/students/pictures/${studentBio.picture}`}/> : <Text></Text>} 
                    </View>
                </View>

    return (<Fragment>{table}</Fragment>)
  };
  
  export default StudentDetailsTable;