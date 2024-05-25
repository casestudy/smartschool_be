import { Font } from '@react-pdf/renderer';

Font.register(
    {
        family: 'Open Sans',
        fonts: [
            { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-regular.ttf' },
        ]
    }
);

Font.register(
    {
        family: 'Open-Sans-Bold',
        fonts: [
            { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600.ttf', fontWeight: 600 }
        ]
    }
);

Font.register(
    {
        family: 'Open-Sans-Italic',
        fonts: [
            { src: 'https://cdn.jsdelivr.net/npm/open-sans-all@0.1.3/fonts/open-sans-600italic.ttf', fontWeight: 600, fontStyle: 'italic'}
        ]
    }
);

export const RegisteredFonts = {
    OpenSans: 'Open Sans',
    BoldSans: 'Open-Sans-Bold',
    ItalicsSans: 'Open-Sans-Italic'
}