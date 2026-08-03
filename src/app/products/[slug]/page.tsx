import RelatedProducts from "@/components/RelatedProducts";
import SingleProduct from "@/components/SingleProduct";
import ProductLoader from "@/components/loader/ProductLoader";
import fetchData from "@/lib/fetchDataFromApi";
import { Metadata, ResolvingMetadata } from "next";
import { Suspense } from "react";

type SingleProductPageProps = {
  params: {
    slug: string;
  };
};

export async function generateMetadata(
  { params }: SingleProductPageProps,
  parent: ResolvingMetadata
): Promise<Metadata> {
  try {
    const res = await fetchData.get(`/products/${params.slug}`);
    const product = res.data;

    return {
      title: product?.title || "Product Not Found",
      description: product?.description || "",
    };
  } catch {
    return {
      title: "Product Not Found",
    };
  }
}

const SingleProductPage = async ({
  params,
}: SingleProductPageProps) => {
  let product = null;

  try {
    const res = await fetchData.get(`/products/${params.slug}`);
    product = res.data;
  } catch (err) {
    console.error(err);
  }

  return (
    <section className="single-product-page bg-secondary dark:bg-background">
      {product ? (
        <>
          <SingleProduct product={product} />

          <Suspense
            fallback={
              <div className="container">
                <ProductLoader />
              </div>
            }
          >
            <div className="bg-accent pb-20 pt-10">
              <div className="container">
                <h1 className="mb-7 text-3xl font-semibold">
                  You May Also Like
                </h1>

                <div className="grid-layout">
                  {product.categories?.map((item: string) => (
                    <RelatedProducts
                      key={item}
                      shop_category={product.shop_category}
                      category={item}
                    />
                  ))}
                </div>
              </div>
            </div>
          </Suspense>
        </>
      ) : (
        <div className="h-screen flex items-center justify-center text-3xl font-semibold">
          Product Not Found
        </div>
      )}
    </section>
  );
};

export default SingleProductPage;
