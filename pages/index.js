import React from "react"
import Head from "@docusaurus/Head"
import Link from "@docusaurus/Link"
import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import Layout from "@theme/Layout"
import clsx from "clsx"
import styles from "./index.module.css"

const FEATURES = [
    {
        title: "📘Fully Documented API",
        description: "Structix uses Moonwave to provide rich, typed documentation with clear method descriptions, making it easy to learn and integrate.",
        image: "https://cdn-icons-png.flaticon.com/512/4708/4708375.png"
    },
    {
        title: "🎯Roblox-Centric Design",
        description: "Designed specifically for Roblox development, Structix follows Luau conventions and plays well with DataStores, state managers, and module loaders.",
        image: "https://cdn-icons-png.flaticon.com/512/18599/18599433.png"
    },
    {
        title: "🧠Strict & Predictable Behavior",
        description: "Every structure somewhat enforces strict typing and safe mutation patterns, helping you avoid hidden bugs and stay in full control of your data.",
        image: "https://cdn-icons-png.flaticon.com/512/11268/11268618.png"
    }
]

function Feature({ image, title, description }) {
    return (
        <div className={clsx("col col--4")}>
            {image && (
                <div className="text--center">
                    <img className={styles.featureSvg} alt={title} src={image} />
                </div>
            )}
            <div className="text--center padding-horiz--md">
                <h3>{title}</h3>
                <p>{description}</p>
            </div>
        </div>
    )
}

export function HomepageFeatures() {
    if (!FEATURES) return null

    return (
        <section className={styles.features}>
            <div className="container">
                <div className="row">
                    {FEATURES.map((props, idx) => (
                        <Feature key={idx} {...props} />
                    ))}
                </div>
            </div>
        </section>
    )
}

function HomepageHeader() {
    const { siteConfig } = useDocusaurusContext()
    const bannerImage = siteConfig.customFields.bannerImage
    const hasBannerImage = bannerImage ? true : false
    const heroBannerStyle = hasBannerImage ? { backgroundImage: `url("${bannerImage}")` } : null

    const titleClassName = clsx("hero__title", {
        [styles.titleOnBannerImage]: hasBannerImage
    })
    const taglineClassName = clsx("hero__subtitle", {
        [styles.taglineOnBannerImage]: hasBannerImage
    })

    return (
        <header className={clsx("hero", styles.heroBanner)} style={heroBannerStyle}>
            <div className="container">
                <h1 className={titleClassName}>{siteConfig.title}</h1>
                <p className={taglineClassName}>{siteConfig.tagline}</p>
                <p className={clsx(taglineClassName, styles.credit)}>
                    🌟Built by <a href="https://github.com/wiindsom" target="_blank" rel="noopener noreferrer">wiindsom</a>🌟
                </p>
                <div className={styles.buttons}>
                    <Link
                        className="button button--secondary button--lg"
                        to="/docs/intro"
                    >
                        Get Started →
                    </Link>
                </div>
            </div>
        </header>
    )
}

export default function Home() {
    const { siteConfig, tagline } = useDocusaurusContext()
    return (
        <Layout title={siteConfig.title} description={tagline}>
            <Head>
                <title>Structix</title>
                <meta property="og:title" content="Structix" />
                <meta property="og:description" content="Type-Safe, Java-Inspired Data Structures for Roblox." />
                <meta property="og:image" content="https://wiindsom.github.io/Structix/og-image.jpg" />
                <meta property="og:site_name" content="wiindsom" />
                <meta name="theme-color" content="#B19CD7" />
                <meta name="twitter:card" content="summary_large_image" />
            </Head>
            <HomepageHeader />
            <main>
                <HomepageFeatures />
                <div className="container">{/***readme***/}</div>
            </main>
        </Layout>
    );
}


