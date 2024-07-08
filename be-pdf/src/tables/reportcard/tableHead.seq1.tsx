import React from 'react';
import {Text, View, StyleSheet, Font } from '@react-pdf/renderer';
import { RegisteredFonts } from '../../fonts/font';

const borderColor = '#000000';

const styles = StyleSheet.create({
    container: {
        display: 'flex',
        flexDirection: 'row',
        borderBottomColor: '#000000',
        borderTopColor: '#000000',
        borderBottomWidth: 1,
        backgroundColor: '#FFF',
        alignItems: 'center',
        height: 11,
        textAlign: 'left',
        fontSize: 7,
        fontFamily: RegisteredFonts.BoldSans,
        fontWeight: 'bold',
    },

    subjects: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '20%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        fontWeight: 1000,
        height: '100%'
    },

    coef: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '5%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        height: '100%'
        
    },

    seq1: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '10%',
        borderRightColor: '#000000',
        borderRightWidth: 0.5,
        paddingLeft: 5,
        height: '100%'
    },

    remarks : {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        width: '20%',
        paddingLeft: 5,
        fontWeight: 1000,
        height: '100%'
    }
    
  });

  const Seq1TableHeader = () => (
    <View style={styles.container}>
        <View style={styles.subjects}>
            <Text>Subjects & Teacher's Name</Text>
        </View>
        <View style={styles.coef}>
            <Text>Coef</Text>
        </View>
        <View style={styles.seq1}>
            <Text>Seq1</Text>
        </View>
        <View style={styles.seq1}>
            <Text>Mark*Coef</Text>
        </View>
        <View style={styles.seq1}>
            <Text>Rank</Text>
        </View>
        <View style={styles.seq1}>
            <Text>Highest</Text>
        </View>
        <View style={styles.seq1}>
            <Text>Lowest</Text>
        </View>
        <View style={styles.seq1}>
            <Text>General avg</Text>
        </View>
        <View style={styles.remarks}>
            <Text>Teacher's Remark</Text>
        </View>
    </View>
  );
  
  export default Seq1TableHeader