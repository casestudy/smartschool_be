import React from "react";
import ReactPDF, {
    Page,
    Text,
    View,
    Document,
    StyleSheet,
    Font,
    Image
} from "@react-pdf/renderer";
import StudentFeeItemsTable from '../tables/studentreceipts/table'

type TemplateData = {
    name_en: string;
    name_fr: string;
    box_en: string;
    box_fr: string;
    items: {
        surname: string;
        othernames: string;
        dob: string;
        userid: number;
        matricule: string;
        doe: string;
        descript: string;
    };
    details: {
    	surname: string;
    	othernames: string;
    	userid: number;
        matricule: string;
        doe: string;
        descript: string;
        cname: string;
        cabbrev: string;
    };
    year: string;
};

interface PDFProps {
    data: TemplateData;
}

Font.register({
    family: 'Open Sans',
    fonts: [
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
    ]
});

const logo = '../be/assets/logo-1.png';

const styles = StyleSheet.create({
    page: {
        backgroundColor: "#FFF",
    },
    section: {
        margin: 10,
        padding: 10,
    },
    heading: {
        fontWeight: 1000,
    },
    statement: {
        fontSize: 20,
        color: "#131925",
        lineHeight: 1.4,
        marginBottom: 4,
    },
    divider: {
        width: "100%",
        height: 1,
        backgroundColor: "#999999",
        margin: "24px 0 24px 0"
    },
    paragraph1: {
        //fontSize: 12,
        fontWeight: 1000,
        color: "#131925",
    },
    columnParent: {
        fontFamily: "Open Sans",
        flexDirection: "row",
        justifyContent: "space-between",
        fontSize: 8,
        lineHeight: 2,
        fontWeight: 2000,
    },
    columnStart: {
        fontFamily: "Open Sans",
        flex: 2,
        textAlign: "center",
        fontWeight: "bold",
    },
    columnMiddle: {
        display: "flex",
        justifyContent: "center",
    },
    columnEnd: {
        fontFamily: "Open Sans",
        flex: 2,
        textAlign: "center",
        fontWeight: "bold",
    },
    schoolName: {
        fontFamily: "Open Sans",
        fontWeight: "bold",
        color: "#800000"
    },
    image: {
        height: 60,
        width: 60
    },
    title: {
        fontFamily: "Open Sans",
        fontWeight: "bold",
        textDecoration: "underline",
        textAlign: "center",
        paddingTop: 10,
        fontSize: 10,
    },
    details: {
        flexDirection: "row",
        justifyContent: "space-between",
        fontSize: 8,
        paddingTop: 10,
        fontFamily: "Open Sans",
        fontWeight: "bold"
    },
    pageNumber: {
        position: "absolute",
        fontSize: 8,
        bottom: 30,
        left: 0,
        right: 0,
        textAlign: "center",
        color: "grey"
    }
});

const PDF = ({ data }: PDFProps) => {
    return (
        <Document author="Smart School LTD" title={`Fee Receipt: ${data.details.surname} ${data.details.othernames}`} subject={`Fee Receipt: ${data.details.surname} ${data.details.othernames}`}>
            <Page size="A4" style={styles.page}>
                <View style={styles.section}>
                    <View style={styles.columnParent}>
                        <View style={styles.columnStart}>
                            <Text style={styles.heading}>REPUBLIQUE DU CAMEROUN</Text>
                            <Text style={styles.paragraph1}>Paix - Travail - Patrie</Text>
                            <Text style={styles.paragraph1}>***************</Text>
                            <Text style={styles.paragraph1}>MINISTERE DES ENSEIGNEMENTS SECONDAIRES</Text>
                            <Text style={styles.schoolName}>{data.name_fr}</Text>
                            <Text style={styles.paragraph1}>{data.box_fr}</Text>
                        </View>
                        <View style={styles.columnMiddle}>
                            <Image style={styles.image} source={logo}/>
                        </View>
                        <View style={styles.columnEnd}>
                            <Text style={styles.paragraph1}>REPUBLIC OF CAMEROON</Text>
                            <Text style={styles.paragraph1}>Peace - Work - Fatherland</Text>
                            <Text style={styles.paragraph1}>***************</Text>
                            <Text style={styles.paragraph1}>MINISTRY OF SECONDARY EDUCATION</Text>
                            <Text style={styles.schoolName}>{data.name_en}</Text>
                            <Text style={styles.paragraph1}>{data.box_en}</Text>
                        </View>
                    </View>
                    <View style={styles.title}>
                        <Text>ANNUAL SCHOOL FEE PAYMENT SUMMARY -- RECAPITULATIVE ANNUEL DES FRAIS EXIGIBLES</Text>
                        <Text>Academic year / Année académique -- {data.year}</Text>
                    </View>
                    <View style={styles.details}>
                    	<Text>Name/Nom: {`${data.details[0].surname} (${data.details[0].othernames})`}</Text>
                    	<Text>Matricule: {`${data.details[0].matricule}`}</Text>
                        <Text>Classe/Class: {`${data.details[0].cname} (${data.details[0].cabbrev})`}</Text>
                        <Text>Born on/Né(e) le: {`${data.details[0].dob} at/à ${data.details[0].pob}`}</Text>
                    </View>

                    <StudentFeeItemsTable fees={data.items}/>
                </View>
            </Page>
        </Document>
    );
};

export default async (data: TemplateData) => {
    return await ReactPDF.renderToStream(<PDF {...{ data }} />);
};