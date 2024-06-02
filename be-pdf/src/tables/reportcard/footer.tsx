import React from 'react';
import {View, StyleSheet } from '@react-pdf/renderer';
import ReportCardTableFooters from './tableFooter'

const styles = StyleSheet.create({
    tableContainer: {
        display: 'flex',
        flexDirection: 'row',
        borderWidth: 1,
        borderColor: '#000000',
        flexWrap: 'wrap',
        marginRight: 30,
        marginTop: 50
    },
});

  const ReportCardFooter = ({details, calendar, subjects, alldata}) => (
    <View style={styles.tableContainer}>
        <ReportCardTableFooters details={details} calendar={calendar} subjects={subjects} alldata={alldata}/>
    </View>
  );
  
  export default ReportCardFooter;