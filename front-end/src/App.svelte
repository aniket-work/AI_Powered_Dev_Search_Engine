<!-- App.svelte -->
<script>
    import { tick } from "svelte";
    import SvelteMarkdown from "svelte-markdown";
    import botImage from "./assets/images/bot.jpeg";
    import meImage from "./assets/images/me.jpeg";
    import MdLink from "./lib/MdLink.svelte";
    import External from "./lib/External.svelte";
    import { chatStates, chatStore } from "./lib/chat.store.js";
    import Modal from "./lib/Modal.svelte";
    import { generationStore } from "./lib/generation.store";

    let ragMode = true;
    let question = "How can I calculate age from date of birth in Cypher?";
    let shouldAutoScroll = true;
    let input;
    let senderImages = { bot: botImage, me: meImage };
    let generationModalOpen = false;

    function send() {
        chatStore.send(question, ragMode);
    }

    function scrollToBottom(node, _) {
        const scroll = () => node.scrollTo({ top: node.scrollHeight });
        scroll();
        return { update: () => shouldAutoScroll && scroll() };
    }

    function scrolling(e) {
        shouldAutoScroll = e.target.scrollTop + e.target.clientHeight > e.target.scrollHeight - 55;
    }

    function generateTicket(text) {
        generationStore.generate(text);
        generationModalOpen = true;
    }

    $: $chatStore.state === chatStates.IDLE && input && focus(input);
    async function focus(node) {
        await tick();
        node.focus();
    }
    // send();
</script>

<main class="h-full text-sm bg-gradient-to-t from-blue-50 to-blue-100 bg-fixed overflow-hidden">
    <div on:scroll={scrolling} class="flex h-full flex-col py-12 overflow-y-auto scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-blue-200" use:scrollToBottom={$chatStore}>

        <div class="text-sm w-full fixed bottom-16">
            <!-- Question section -->
            <div class="shadow-lg bg-blue-50 rounded-lg w-4/5 xl:w-2/3 2xl:w-1/2 mx-auto gap-10">
                <form class="rounded-md w-full bg-white p-2 m-0" on:submit|preventDefault={send}>
                    <input
                        placeholder="What coding related question can I help you with?"
                        disabled={$chatStore.state === chatStates.RECEIVING}
                        class="text-lg w-full bg-white focus:outline-none px-4"
                        bind:value={question}
                        bind:this={input}
                        type="text"
                    />
                </form>
            </div>

            <div class="w-4/5 mx-auto flex flex-col mb-32">
                {#each $chatStore.data as message (message.id)}
                    {#if message.from === "me"}
                        <div class="text-sm mb-4 pl-4">
                            <div class="border-l-4 border-blue-500 pl-2 p-2 mb-2">Answering for: {message.text}</div>
                        </div>
                    {/if}
                    {#if message.from === "bot"}
                        <div class="max-w-[80%] min-w-[40%] rounded-lg p-4 mb-4 overflow-x-auto bg-white border border-blue-200">
                            <SvelteMarkdown source={message.text} renderers={{ link: MdLink }} />
                        </div>
                    {/if}
                {/each}
            </div>
        </div>
    </div>
</main>


{#if generationModalOpen}
    <Modal title="my title" text="my text" on:close={() => (generationModalOpen = false)} />
{/if}

<style>
    :global(pre) {
        @apply bg-gray-100 rounded-lg p-4 border border-blue-200;
    }
    :global(code) {
        @apply text-blue-500;
    }
</style>
