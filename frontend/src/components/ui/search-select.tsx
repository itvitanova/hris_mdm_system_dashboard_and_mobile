"use client";
import {
  Children,
  isValidElement,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type ReactNode,
  type SelectHTMLAttributes,
} from "react";
import { Check, ChevronDown, Search } from "lucide-react";

type Choice = { value: string; label: string; disabled: boolean };
function nodeText(node: ReactNode): string {
  return Children.toArray(node)
    .map((n) =>
      isValidElement<{ children?: ReactNode }>(n)
        ? nodeText(n.props.children)
        : String(n),
    )
    .join("");
}
function choices(nodes: ReactNode): Choice[] {
  return Children.toArray(nodes).flatMap((node) => {
    if (
      !isValidElement<{
        value?: string;
        disabled?: boolean;
        children?: ReactNode;
      }>(node)
    )
      return [];
    if (node.type !== "option") return choices(node.props.children);
    const label = nodeText(node.props.children);
    return [
      {
        value: String(node.props.value ?? label),
        label,
        disabled: !!node.props.disabled,
      },
    ];
  });
}

/** Searchable single/multiple selection with a native form value and keyboard support. */
export function SearchSelect(props: SelectHTMLAttributes<HTMLSelectElement>) {
  const {
    children,
    value,
    defaultValue,
    disabled,
    multiple,
    className,
    ...native
  } = props;
  const id = useId();
  const root = useRef<HTMLDivElement>(null),
    select = useRef<HTMLSelectElement>(null),
    trigger = useRef<HTMLButtonElement>(null),
    search = useRef<HTMLInputElement>(null);
  const options = useMemo(() => choices(children), [children]);
  const [chosen, setChosen] = useState<string[]>(() =>
    [defaultValue ?? options[0]?.value ?? ""].flat().map(String),
  );
  const selected = value === undefined ? chosen : [value].flat().map(String);
  const [open, setOpen] = useState(false),
    [query, setQuery] = useState(""),
    [index, setIndex] = useState(0),
    [invalid, setInvalid] = useState(false),
    [label, setLabel] = useState("");
  const results = options.filter(
    (o) =>
      !o.disabled &&
      o.label.toLocaleLowerCase("id").includes(query.toLocaleLowerCase("id")),
  );
  useEffect(() => {
    const host = root.current?.closest("label");
    const caption = host
      ? Array.from(host.children).find((element) => element.tagName === "SPAN")
          ?.textContent
      : "";
    const directText = host
      ? Array.from(host.childNodes)
          .filter((node) => node.nodeType === Node.TEXT_NODE)
          .map((node) => node.textContent || "")
          .join(" ")
          .trim()
      : "";
    setLabel(caption || directText || props["aria-label"] || "Pilihan");
  }, []);
  useEffect(() => {
    if (open) search.current?.focus();
  }, [open]);
  useEffect(() => {
    setIndex(0);
  }, [query]);
  useEffect(() => {
    if (open)
      document
        .getElementById(`${id}-${index}`)
        ?.scrollIntoView({ block: "nearest" });
  }, [id, index, open, query]);
  function pick(option: Choice) {
    if (!select.current) return;
    const next = multiple
      ? selected.includes(option.value)
        ? selected.filter((v) => v !== option.value)
        : [...selected, option.value]
      : [option.value];
    for (const item of select.current.options)
      item.selected = next.includes(item.value);
    setChosen(next);
    setInvalid(false);
    select.current.dispatchEvent(new Event("change", { bubbles: true }));
    if (!multiple) {
      setOpen(false);
      trigger.current?.focus();
    }
  }
  const display = options
    .filter((o) => selected.includes(o.value))
    .map((o) => o.label)
    .join(", ");
  return (
    <div
      className={`search-select ${className || ""}`}
      ref={root}
      onBlur={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget)) setOpen(false);
      }}
    >
      <button
        ref={trigger}
        type="button"
        className="search-select-trigger"
        role="combobox"
        aria-label={props["aria-label"] || label}
        aria-expanded={open}
        aria-controls={`${id}-options`}
        aria-haspopup="listbox"
        aria-invalid={invalid || undefined}
        disabled={disabled}
        onClick={() => {
          setQuery("");
          setOpen(!open);
        }}
        onKeyDown={(e) => {
          if (["ArrowDown", "ArrowUp"].includes(e.key)) {
            e.preventDefault();
            setOpen(true);
          }
        }}
      >
        <span>
          {display ||
            (disabled ? "Pilih departemen terlebih dahulu" : "Pilih data")}
        </span>
        <ChevronDown size={16} />
      </button>
      <select
        {...native}
        ref={select}
        value={multiple ? selected : selected[0] || ""}
        disabled={disabled}
        multiple={multiple}
        hidden
        tabIndex={-1}
        aria-hidden="true"
        onInvalid={(e) => {
          e.preventDefault();
          setInvalid(true);
          setOpen(true);
          trigger.current?.focus();
        }}
        onChange={(event) => {
          setChosen(
            Array.from(event.currentTarget.selectedOptions).map((o) => o.value),
          );
          props.onChange?.(event);
        }}
      >
        {children}
      </select>
      {open && !disabled && (
        <div className="search-select-popover">
          <div className="search-select-search">
            <Search size={16} />
            <input
              ref={search}
              aria-label={`Cari ${label.replace(/\s*\*$/, "").toLowerCase()}`}
              value={query}
              placeholder="Ketik untuk mencari…"
              autoComplete="off"
              aria-controls={`${id}-options`}
              aria-activedescendant={
                results[index] ? `${id}-${index}` : undefined
              }
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === "Escape") {
                  e.preventDefault();
                  e.stopPropagation();
                  setOpen(false);
                  trigger.current?.focus();
                }
                if (e.key === "ArrowDown" || e.key === "ArrowUp") {
                  e.preventDefault();
                  setIndex((n) =>
                    Math.max(
                      0,
                      Math.min(
                        results.length - 1,
                        n + (e.key === "ArrowDown" ? 1 : -1),
                      ),
                    ),
                  );
                }
                if (e.key === "Enter") {
                  e.preventDefault();
                  if (results[index]) pick(results[index]);
                }
              }}
            />
          </div>
          <div
            id={`${id}-options`}
            role="listbox"
            aria-label={props["aria-label"] || label}
            aria-multiselectable={multiple || undefined}
            className="search-select-options"
          >
            {results.map((o, i) => (
              <button
                key={o.value}
                id={`${id}-${i}`}
                type="button"
                role="option"
                aria-selected={selected.includes(o.value)}
                className={i === index ? "is-highlighted" : ""}
                onMouseDown={(e) => e.preventDefault()}
                onClick={() => pick(o)}
              >
                <span>{o.label}</span>
                {selected.includes(o.value) && <Check size={16} />}
              </button>
            ))}
            {!results.length && (
              <p role="status">Tidak ada pilihan yang sesuai.</p>
            )}
          </div>
        </div>
      )}
      {invalid && (
        <small role="alert">Pilih salah satu data yang tersedia.</small>
      )}
    </div>
  );
}
