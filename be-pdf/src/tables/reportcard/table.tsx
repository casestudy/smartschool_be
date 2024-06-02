import React from 'react';
import {View, StyleSheet } from '@react-pdf/renderer';
import ReportCardTableHeader from './tableHead'
import ReportCardTableRows from './tableRows'

const styles = StyleSheet.create({
    tableContainer: {
        display: 'flex',
        flexDirection: 'row',
        borderWidth: 1,
        borderColor: '#000000',
        flexWrap: 'wrap',
        marginRight: 30
    },
});

  const ReportCardTable = ({details, calendar, subjects, alldata}) => (
    <View style={styles.tableContainer}>
        <ReportCardTableHeader calendar={calendar}/>
        <ReportCardTableRows details={details} calendar={calendar} subjects={subjects} alldata={alldata}/>
    </View>
  );
  
  export default ReportCardTable;