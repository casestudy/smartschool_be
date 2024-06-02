import React, { Fragment } from 'react';
import {Text, View, StyleSheet, Font } from '@react-pdf/renderer';
import Seq1TableHeader from './tableHead.seq1';

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

  const ReportCardTableHeader = ({calendar}) => {

    const seq = calendar[0].etype ;

    let head: any;

    switch (seq) {
        case 'seq1':
            head = <Seq1TableHeader/> ;
            break;
    
        default:
            break;
    }

    return (<Fragment>{head}</Fragment>)
  };
  
  export default ReportCardTableHeader