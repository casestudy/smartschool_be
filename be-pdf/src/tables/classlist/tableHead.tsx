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
        width: '3%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
    },
    name: {
        width: '27%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    matricule: {
        width: '10%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    sequence: {
        width: '10%',
        borderRightColor: borderColor,
        borderRightWidth: 0.5,
        paddingLeft: 5,
    },
    // sequence2: {
    //     width: '10%',
    //     borderRightColor: borderColor,
    //     borderRightWidth: 0.5,
    //     paddingLeft: 5,
    // },
    // sequence3: {
    //     width: '10%',
    //     borderRightColor: borderColor,
    //     borderRightWidth: 0.5,
    //     paddingLeft: 5,
    // },
    // sequence4: {
    //     width: '10%',
    //     borderRightColor: borderColor,
    //     borderRightWidth: 0.5,
    //     paddingLeft: 5,
    // },
    // sequence5: {
    //     width: '10%',
    //     borderRightColor: borderColor,
    //     borderRightWidth: 0.5,
    //     paddingLeft: 5,
    // },
    sequence6: {
        width: '10%',
        paddingLeft: 5,
    },
  });

  const ClassListTableHeader = () => (
    <View style={styles.container}>
        <Text style={styles.sn}>SN</Text>
        <Text style={styles.name}>Name</Text>
        <Text style={styles.matricule}>Matricule</Text>
        <Text style={styles.sequence}>Sequence 1</Text>
        <Text style={styles.sequence}>Sequence 2</Text>
        <Text style={styles.sequence}>Sequence 3</Text>
        <Text style={styles.sequence}>Sequence 4</Text>
        <Text style={styles.sequence}>Sequence 5</Text>
        <Text style={styles.sequence6}>Sequence 6</Text>
    </View>
  );
  
  export default ClassListTableHeader