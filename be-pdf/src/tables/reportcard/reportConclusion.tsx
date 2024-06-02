import React, { Fragment } from 'react';
import {StyleSheet, Font, View, Text } from '@react-pdf/renderer';
import Seq1TableFoot from './tableFooter.seq1';

Font.register({
    family: 'Open Sans',
    fonts: [
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
    ]
});


const ReportCardConclusion = ({calendar}) => {

const seq = calendar[0].etype ;

let row: any;

const styles = StyleSheet.create({
    conclusion: {
        display: 'flex',
        flexDirection: 'row',
        backgroundColor: '#FFF',
        fontSize: 6,
        justifyContent: 'center',
        alignContent: 'center',
        alignItems: 'center',
        color: '#800000',
        marginTop: 5
    }
});

switch (seq) {
    case 'seq1':
        row = <View style={styles.conclusion}>
                <Text>Build and realised by Smart Systems Corp. Contact us at (+237) 679 734 580 / (+237) 696 449 761 / (+237) 674 957 860</Text>
              </View>;
        break;

    default:
        break;
}

return (<Fragment>{row}</Fragment>)
};

export default ReportCardConclusion;