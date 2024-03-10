<!-- App.svelte -->

<script>
    import { tick } from "svelte";
    import SvelteMarkdown from "svelte-markdown";
    import botImage from "./assets/images/search_icon.jpg";
    import meImage from "./assets/images/me.jpeg";
    import MdLink from "./lib/MdLink.svelte";
    import External from "./lib/External.svelte";
    import { chatStates, chatStore } from "./lib/chat.store.js";
    import Modal from "./lib/Modal.svelte";
    import { generationStore } from "./lib/generation.store";

    let ragMode = true;
    let question = "";
    let shouldAutoScroll = true;
    let input;
    let senderImages = { bot: botImage, me: meImage };
    let generationModalOpen = false;

    function send() {
        if (question.trim() !== "") {
            chatStore.send(question, ragMode);
            question = ""; // Clear the input field after sending
        }
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

<main class="h-screen flex flex-col justify-center items-center bg-gradient-to-b from-blue-50 to-blue-100">
    <div class="text-center mb-10">
        <img src={botImage} alt="Logo" class="mx-auto mb-12 w-44 h-40 rounded-full" />
        <h1 class="text-3xl font-bold text-blue-600">Graph Based AI-Powered Search Engine</h1>
    </div>

    <div class="w-full max-w-7xl p-4 bg-white rounded-lg shadow-lg">
        <div class="flex flex-col h-96 overflow-y-auto scrollbar-thin scrollbar-thumb-blue-500 scrollbar-track-blue-200" use:scrollToBottom={$chatStore}>
            <div on:scroll={scrolling} class="flex flex-col flex-grow">
                {#each $chatStore.data as message (message.id)}
                    {#if message.from === "me"}
                        <div class="text-sm mb-4 pl-4">
                            <div class="border-l-4 border-blue-500 pl-2 p-2 mb-2"><span class="font-bold">Answering for:</span> {message.text}</div>
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

        <form class="mt-4" on:submit|preventDefault={send}>
           <div class="flex">
                          <input
                              placeholder=""
                              disabled={$chatStore.state === chatStates.RECEIVING}
                              class="flex-grow text-lg bg-gray-100 focus:outline-none px-4 py-2 rounded-l-lg"
                              bind:value={question}
                              bind:this={input}
                              type="text"
                          />
                          <button class="bg-transparent hover:bg-transparent text-blue-300 font-bold py-4 px-4 rounded-r-lg flex items-center" on:click={send}>
                              <svg class="h-8 w-9" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                                          <path d="M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z" />
                                      </svg>
                          </button>
                      </div>

        </form>
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

    @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css');

</style>