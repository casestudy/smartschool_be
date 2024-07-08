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
    general: {
        fontSize: 7
    },
    container: {
        display: 'flex',
        flexDirection: 'column',
        borderColor: '#000000',
        border: 1,
        backgroundColor: '#FFF',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: 7,
        width: '100%'
    },
    row1: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%',
        lineHeight: 1.5
    },
    row2: {
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        borderTop: 1,
        borderTopColor: '#000000',
        width: '100%'
    },
    row21: {
        display: 'flex',
        flexDirection: 'column',
        borderRight: 1,
        borderRightColor: '#000000',
        fontSize: 7,
        flexBasis: '30%',
        justifyContent: 'center',
        alignItems: 'center',
        lineHeight: 1.5,
        height: '100%'
    },
    row22: {
        display: 'flex',
        flexDirection: 'column',
        borderRight: 1,
        borderRightColor: '#000000',
        fontSize: 7,
        flexBasis: '40%',
        justifyContent: 'center',
        alignItems: 'center',
        lineHeight: 1.5,
        height: '100%'
    },
    row221: {
        display: 'flex',
        flexDirection: 'column',
        borderBottom: 1,
        borderBottomColor: '#000000',
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%'
    
    },
    row23: {
        display: 'flex',
        flexDirection: 'column',
        flexBasis: '30%',
        justifyContent: 'center',
        alignItems: 'center',
        lineHeight: 1.5
    },
  });

  const SequenceDetailsTable = ({calendar, year}) => {
    const seq = calendar[0].etype ;

    let cal = [];
    switch (seq) {
        case 'seq1':
            cal = ['1st', 'Sequence', 'Séquence'];
            break;
    
        default:
            break;
    }
    const table = 
                <View style={styles.container}>
                    <View style={styles.row1}>
                        <View style={styles.general}><Text>BULLETIN DE NOTES</Text></View>
                        <View style={styles.general}><Text>ACADEMIC REPORT SHEET</Text></View>
                    </View>
                    <View style={styles.row2}>
                        <View style={styles.row21}><Text>{cal[0]}</Text></View>
                        <View style={styles.row22}>
                            <View style={styles.row221}><Text>{cal[1]}</Text></View>
                            <View style={styles.general}><Text>{cal[2]}</Text></View>
                        </View>
                        <View style={styles.row23}><Text>{year}</Text></View>
                    </View>
                </View>

    return (<Fragment>{table}</Fragment>)
  };
  
  export default SequenceDetailsTable;