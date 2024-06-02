import React, { Fragment } from 'react';
import {Text, View, StyleSheet, Font } from '@react-pdf/renderer';
import Seq1TableRow from './tableRows.seq1';

const borderColor = '#000000';

Font.register({
    family: 'Open Sans',
    fonts: [
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
    ]
});

const styles = StyleSheet.create({
    
});

  const ReportCardTableRow = ({details, calendar, subjects, alldata}) => {

    const seq = calendar[0].etype ;

    let row: any;

    switch (seq) {
        case 'seq1':
            row = <Seq1TableRow details={details} subjects={subjects} alldata={alldata}/> ;
            break;
    
        default:
            break;
    }

    return (<Fragment>{row}</Fragment>)
  };
  
  export default ReportCardTableRow