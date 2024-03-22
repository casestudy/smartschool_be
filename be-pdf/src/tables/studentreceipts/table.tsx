import React from 'react';
import {View, StyleSheet } from '@react-pdf/renderer';
import StudentReceiptTableHeader from './tableHead'
import StudentReceiptTableRow from './tableRows'
// import InvoiceTableBlankSpace from './InvoiceTableBlankSpace'
// import InvoiceTableFooter from './InvoiceTableFooter'

const tableRowsCount = 11;

const styles = StyleSheet.create({
    tableContainer: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        marginTop: 20,
        borderWidth: 1,
        borderColor: '#000000',
    },
});

  const StudentReceiptTable = ({fees}) => (
    <View style={styles.tableContainer}>
        <StudentReceiptTableHeader/>
        <StudentReceiptTableRow items={fees}/>
        {/* <InvoiceTableBlankSpace rowsCount={ tableRowsCount - invoice.items.length} />
        <InvoiceTableFooter items={invoice.items} /> */}
    </View>
  );
  
  export default StudentReceiptTable