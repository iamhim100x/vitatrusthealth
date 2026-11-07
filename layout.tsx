import './globals.css';
import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'VitatrustHealth | Trusted pharmacy care', description: 'A connected pharmacy and healthcare experience.' };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }
