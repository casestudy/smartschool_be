import React, {Fragment} from 'react';
import {Text, View, StyleSheet } from '@react-pdf/renderer';

const borderColor = '#000000'
const styles = StyleSheet.create({
    row: {
        flexDirection: 'row',
        borderBottomColor: '#000000',
        borderBottomWidth: 0.5,
        fontSize: 8,
        alignItems: 'center',
        height: 11,
        fontStyle: 'bold',
    },
    sn: {
        width: '3%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    name: {
        width: '27%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        textAlign: 'left',
        paddingLeft: 5,
    },
    matricule: {
        width: '10%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        textAlign: 'left',
        paddingLeft: 5,
    },
    sequence1: {
        width: '10%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence2: {
        width: '10%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence3: {
        width: '10%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence4: {
        width: '10%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence5: {
        width: '10%',
        textAlign: 'left',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence6: {
        width: '10%',
        textAlign: 'left',
        paddingLeft: 5,
    },
  });

// const items = [
//     {
//         "sn": 1,
//         "name": "Femencha Azombo Fabrice",
//         "matricule": "2012A091"
//     },
//     {
//         "sn": 2,
//         "name": "Tatou Roberto",
//         "matricule": "2012A092"
//     },
//     {
//         "sn": 3,
//         "name": "Ntiege Meek Yan",
//         "matricule": "2012A093"
//     }
// ]

const ClassListTableRow = ({items}) => {
    const rows = items.map((item, index) =>
        <View style={styles.row} key={item.matricule}>
            <Text style={styles.sn}>{index+1}</Text>
            <Text style={styles.name}>{item.surname + ' ' + item.othernames}</Text>
            <Text style={styles.matricule}>{item.matricule}</Text>
            <Text style={styles.sequence1}> </Text>
            <Text style={styles.sequence2}> </Text>
            <Text style={styles.sequence3}> </Text>
            <Text style={styles.sequence4}> </Text>
            <Text style={styles.sequence5}> </Text>
            <Text style={styles.sequence6}> </Text>
        </View>
    );
    return (<Fragment>{rows}</Fragment> )
};
  
export default ClassListTableRow