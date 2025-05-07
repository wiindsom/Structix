import React from 'react';
import Head from '@docusaurus/Head';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import clsx from 'clsx';
import styles from './index.module.css';

const FEATURES = [
  {
    title: 'Fast & Optimized',
    description: 'Structix is built with performance in mind, using efficient Lua-based algorithms for blazing-fast data access.',
    image: 'https://cdn-icons-png.flaticon.com/512/733/733609.png'
  },
  {
    title: 'Modern API',
    description: 'Clean, class-based design with Moonwave documentation and type annotations for clarity and ease of use.',
    image: 'https://cdn-icons-png.flaticon.com/512/733/733609.png'
  },
  {
    title: 'Roblox Ready',
    description: 'Designed specifically for Roblox developers. 100% compatible with Luau and optimized for DataStores.',
    image: 'https://cdn-icons-png.flaticon.com/512/733/733609.png'
  }
];

function Feature({ image, title, description }) {
  return (
    <div className={clsx('col col--4')}>
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
  );
}

function HomepageFeatures() {
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
  );
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  const bannerImage = siteConfig.customFields?.bannerImage;
  const hasBannerImage = Boolean(bannerImage);
  const heroBannerStyle = hasBannerImage ? { backgroundImage: `url("${bannerImage}")` } : null;

  const titleClassName = clsx('hero__title', {
    [styles.titleOnBannerImage]: hasBannerImage
  });
  const taglineClassName = clsx('hero__subtitle', {
    [styles.taglineOnBannerImage]: hasBannerImage
  });

  return (
    <header className={clsx('hero', styles.heroBanner)} style={heroBannerStyle}>
      <div className="container">
        <h1 className={titleClassName}>{siteConfig.title}</h1>
        <p className={taglineClassName}>{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link className="button button--secondary button--lg" to="/docs/intro">
            Get Started →
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig, tagline } = useDocusaurusContext();
  return (
    <Layout title={siteConfig.title} description={tagline}>
      <Head>
        <title>Structix</title>
        <meta property="og:title" content="Structix" />
        <meta property="og:description" content="A data structure library for Roblox developers." />
        <meta property="og:image" content="https://wiindsom.github.io/Structix/og-image.jpg" />
        <meta property="og:site_name" content="wiindsom" />
        <meta name="theme-color" content="#B19CD7" />
        <meta name="twitter:card" content="summary_large_image" />
      </Head>
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <div className="container">{/*** Additional homepage content can go here ***/}</div>
      </main>
    </Layout>
  );
}
