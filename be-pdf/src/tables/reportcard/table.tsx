import React from 'react';
import {View, StyleSheet } from '@react-pdf/renderer';
import ReportCardTableHeader from './tableHead'
// import InvoiceTableBlankSpace from './InvoiceTableBlankSpace'
// import InvoiceTableFooter from './InvoiceTableFooter'

const tableRowsCount = 11;

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

  const ClassListTable = ({details, calendar}) => (
    <View style={styles.tableContainer}>
        <ReportCardTableHeader calendar={calendar}/>
    </View>
  );
  
  export default ClassListTable