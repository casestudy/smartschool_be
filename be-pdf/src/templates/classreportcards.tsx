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
import SequenceDetails from '../tables/reportcard/sequenceDetails';
import StudentDetails from '../tables/reportcard/studentDetails';
import ReportTable from '../tables/reportcard/table';
import { RegisteredFonts } from '../fonts/font';

type TemplateData = {
    name_en: string;
    name_fr: string;
    box_en: string;
    box_fr: string;
    student_details: any;
    calendar_details: any;
    classroom_details: any;
    subject_details: any;
    details: string;
    year: string;
};

interface PDFProps {
    data: TemplateData;
}

const logo = '../be/assets/logo-1.png';

const styles = StyleSheet.create({
    page: {
        backgroundColor: "#FFF",
        margin: 15
    },
    section: {
        fontSize: 9,
        display: 'flex',
        flexDirection: 'column'
    },
    heading: {
        fontWeight: 1000,
        fontSize: 8
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
        fontWeight: 1000,
        color: "#131925",
    },
    columnParent: {
        flexDirection: "row",
        fontSize: 7,
        lineHeight: 2,
        display: "flex",
        flexGrow: 1,
        fontFamily: RegisteredFonts.BoldSans,
        fontWeight: 'bold'
    },
    columnStart: {
        fontFamily: "Open Sans",
        display: 'flex',
        alignItems: "center",
        justifyContent: 'center',
        fontWeight: "bold",
        flexBasis: '35%',
        fontSize: 7,
        lineHeight: 2.5
    },
    columnMiddle: {
        display: "flex",
        justifyContent: "center",
        alignItems: 'center',
        flexDirection: 'column',
        flexBasis: '25%'
    },
    columnEnd: {
        fontFamily: "Open Sans",
        display: 'flex',
        alignItems: "center",
        justifyContent: 'center',
        fontWeight: "bold",
        flexBasis: '35%',
        fontSize: 7,
        lineHeight: 2.5
    },
    schoolName: {
        fontFamily: "Open Sans",
        fontWeight: "bold",
        color: "#800000"
    },
    image: {
        height: 40,
        width: 40,
        marginBottom: 5
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
        <Document author="Smart School LTD" title={"Class report card: "+data.details} subject={"Class report card: "+data.details}>

            {data.student_details.map((entry: any, index: any) => (
                <Page size="A4" style={styles.page} key={index}>                    
                    <View style={styles.section} >
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
                                <SequenceDetails calendar={data.calendar_details} year={data.year}/>
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
                        <StudentDetails student={entry[1]} classroom={data.classroom_details} total={data.student_details.length}/>
                        <ReportTable details={entry[0]} calendar={data.calendar_details} subjects={data.subject_details} alldata={data.student_details}/>
                    </View>
                </Page>
            ))}
            
        </Document>
    );
};

export default async (data: TemplateData) => {
    return await ReactPDF.renderToStream(<PDF {...{ data }} />);
};