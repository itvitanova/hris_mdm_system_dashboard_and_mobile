import type { Locator } from "@playwright/test";

export async function choose(
  scope: Locator,
  name: string,
  option: string | { label?: string; index?: number; value?: string },
) {
  const trigger = scope.getByRole("combobox", {
    name: new RegExp(
      `^${name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}(?: \\*)?$`,
    ),
  });
  const native = trigger.locator("..").locator("select");
  const label = await native.evaluate((select, choice) => {
    const items = Array.from((select as HTMLSelectElement).options);
    const item =
      typeof choice === "string"
        ? items.find((o) => o.value === choice || o.text === choice)
        : choice.index !== undefined
          ? items[choice.index]
          : items.find((o) =>
              choice.label ? o.text === choice.label : o.value === choice.value,
            );
    if (!item)
      throw new Error("Requested choice is absent from available form options");
    return item.text;
  }, option);
  await trigger.click();
  const list = trigger.locator("..");
  await list.getByRole("textbox").fill(label);
  await list.getByRole("option", { name: label, exact: true }).click();
}
