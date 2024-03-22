import React from 'react';
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
    container: {
        flexDirection: 'row',
        borderBottomColor: '#000000',
        borderTopColor: '#000000',
        borderBottomWidth: 1,
        backgroundColor: '#FFF',
        alignItems: 'center',
        height: 11,
        textAlign: 'left',
        flexGrow: 1,
        fontSize: 8,
    },
    sn: {
        width: '5%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5
    },
    item: {
        width: '20%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    amount: {
        width: '20%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    on: {
        width: '15%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    by: {
        width: '20%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    reference: {
        width: '20%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
  });

  const ClassListTableHeader = () => (
    <View style={styles.container}>
        <Text style={styles.sn}>SN</Text>
        <Text style={styles.item}>Item</Text>
        <Text style={styles.amount}>Amount</Text>
        <Text style={styles.on}>Paid On</Text>
        <Text style={styles.by}>Paid By</Text>
        <Text style={styles.reference}>Reference</Text>
    </View>
  );
  
  export default ClassListTableHeader