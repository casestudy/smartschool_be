import React, {Fragment} from 'react';
import {Text, View, StyleSheet } from '@react-pdf/renderer';
import currency from 'currency.js';

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
        paddingRight: 5,
        textAlign: 'right'
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


const StudentReceiptTableRow = ({items}) => {
    const rows = items.map((item, index) =>
        <View style={styles.row} key={item.feeid}>          
            <Text style={styles.sn}>{index+1}</Text>
	        <Text style={styles.item}>{item.descript}</Text>
	        <Text style={styles.amount}>{currency(items[0].amount, { symbol: 'XAF ' }).format()}</Text>
	        <Text style={styles.on}>{item.paidon}</Text>
	        <Text style={styles.by}>{item.method}</Text>
	        <Text style={styles.reference}>{item.reference}</Text>
        </View>
    );
    return (<Fragment>{rows}</Fragment> )
};
  
export default StudentReceiptTableRow