import * as am5hierarchy from "@amcharts/amcharts5/hierarchy";
import * as am5 from "@amcharts/amcharts5/index";
import { useEffect } from "react";
import { Graph } from "react-d3-graph";


const Chart = (props: any) => {
  // eslint-disable-next-line react/destructuring-assignment
  // useEffect(() => {
  //   const root = am5.Root.new("chartdiv");
  //
  //   const container = root.container.children.push(
  //     am5.Container.new(root, {
  //       width: am5.percent(100),
  //       height: am5.percent(100),
  //       layout: root.verticalLayout,
  //     })
  //   );
  //
  //   const series = container.children.push(
  //     am5hierarchy.ForceDirected.new(root, {
  //       downDepth: 1,
  //       initialDepth: 2,
  //       topDepth: 1,
  //       valueField: "value",
  //       categoryField: "name",
  //       childDataField: "children",
  //     })
  //   );
  //
  //   series.outerCircles.template.states.create("disabled", {
  //     fillOpacity: 0.5,
  //     strokeOpacity: 0,
  //     strokeDasharray: 0,
  //   });
  //
  //   series.outerCircles.template.states.create("hoverDisabled", {
  //     fillOpacity: 0.5,
  //     strokeOpacity: 0,
  //     strokeDasharray: 0,
  //   });
  //
  //   series.data.setAll([
  //     {
  //       name: "Root",
  //       value: 0,
  //       children: [
  //         {
  //           name: "ETH",
  //           children: [
  //             {
  //               name: "USDT",
  //               children: [
  //                 {
  //                   name: "DAI",
  //                   children: [
  //                     {
  //                       name: "ETH"
  //                     }
  //                   ]
  //                 },
  //                 {
  //                   name: "WBTC",
  //                   children: [
  //                     {
  //                       name: "DAO",
  //                       value: 69,
  //                     },
  //                     {
  //                       name: "CMP",
  //                       value: 85,
  //                     },
  //                   ],
  //                 },
  //                 {
  //                   name: "AAVE",
  //                   value: 48,
  //                 },
  //               ],
  //             },
  //             {
  //               name: "GMT",
  //               value: 27,
  //             },
  //             {
  //               name: "XRT",
  //               children: [
  //                 {
  //                   name: "A0C2A2",
  //                   value: 2,
  //                 },
  //                 {
  //                   name: "A0C2B2",
  //                   children: [
  //                     {
  //                       name: "A0C2B1A3",
  //                       value: 54,
  //                     },
  //                     {
  //                       name: "A0C2B1B3",
  //                       value: 16,
  //                     },
  //                   ],
  //                 },
  //               ],
  //             },
  //             {
  //               name: "A0D1",
  //               value: 89,
  //             },
  //           ],
  //         },
  //       ],
  //     },
  //   ]);
  //   series.set("selectedDataItem", series.dataItems[0]);
  //
  //   return () => {
  //     root.dispose();
  //   };
  // }, []);

  // graph payload (with minimalist structure)
  const data = {
    nodes: [{ id: "ETH" }, { id: "WBTC" }, { id: "CMP" }, { id: "GRT" }, { id: "AAVE" }, { id: "USDT" }, { id: "DAI" }],
    links: [
      { source: "ETH", target: "WBTC" },
      { source: "ETH", target: "CMP" },
      { source: "ETH", target: "AAVE" },
      { source: "ETH", target: "DAI" },
      { source: "ETH", target: "USDT" },
      { source: "USDT", target: "WBTC" },
      { source: "USDT", target: "GRT" },
      { source: "WBTC", target: "USDT" },
      { source: "WBTC", target: "DAI" },
    ],
  };

// the graph configuration, just override the ones you need
  const myConfig = {
    nodeHighlightBehavior: true,
    node: {
      color: "lightgreen",
      size: 120,
      highlightStrokeColor: "blue",
    },
    link: {
      highlightColor: "lightblue",
    },
  };

  const onClickNode = function(nodeId: any) {
    window.alert(`Clicked node ${nodeId}`);
  };

  const onClickLink = function(source: any, target: any) {
    window.alert(`Clicked link between ${source} and ${target}`);
  };

  return <Graph
    id="graph-id" // id is mandatory
    data={data}
    config={myConfig}
    onClickNode={onClickNode}
    onClickLink={onClickLink}
  />;
};
export default Chart;
